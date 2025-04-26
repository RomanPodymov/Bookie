//
//  BooksViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 02/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Combine
import CombineMoya
import DifferenceKit
import Foundation
import Moya
import OrderedCollections

protocol AnyBooksScreen: AnyObject, Sendable {
    @MainActor
    init(searchText: String, previousBook: Book?)
    func onNewDataReceived(oldSet: DataSetType, newSet: DataSetType) async
    func onNewDataError(_ error: BooksViewModelError) async
    func onSearchTextChanged(_ searchText: String) async
}

enum BookLanguage: String {
    // swiftlint:disable identifier_name
    case en
    case cs

    static let `default` = Self.cs
    // swiftlint:enable identifier_name
}

public typealias DataSetKeyType = OrderedSet<String>
typealias DataSetItemType = ArraySection<DataSetKeyType, Book>
typealias DataSetType = [DataSetItemType]

enum BooksViewModelError: Error {
    case noData
    case parseError(Error)
    case requestError(Error)
}

final class BooksViewModel {
    unowned var screen: AnyBooksScreen!

    let searchText: CurrentValueSubject<String, Never>
    var previousBook: Book?

    var allowedLanguages: Set<BookLanguage> = [.cs, .en]
    private var data: BookResponse?
    private var oldSet: DataSetType = .init()
    private var newSet: DataSetType = .init()
    private var cancellables = Set<AnyCancellable>()

    init(screen: AnyBooksScreen!, searchText: String, previousBook: Book?, data: BookResponse? = nil) {
        self.screen = screen
        self.searchText = .init(searchText)
        self.previousBook = previousBook
        self.data = data
        self.searchText.removeDuplicates().sink { [weak self] text in
            _Concurrency.Task { [weak screen = self?.screen] in
                await screen?.onSearchTextChanged(text)
            }
        }.store(in: &cancellables)
    }

    func reloadData() async {
        guard let source = dependenciesContainer.resolve(RemoteDataSource.self) else {
            return
        }
        do {
            let books = try await source.search(text: searchText.value)
            try await source.save(books: books.items)

            data = books
            oldSet = newSet

            let newSetFiltered = books.items.filter { book in
                guard let language = book.volumeInfo.language.flatMap({ BookLanguage(rawValue: $0) }) else {
                    return false
                }
                return allowedLanguages.contains(language)
            }
            let newSet = [DataSetKeyType: [Book]](grouping: newSetFiltered, by: {
                $0.volumeInfo.categories.map { .init($0) } ?? .init()
            }).mapValues {
                $0.sorted(by: \.volumeInfo.title)
            }.map {
                DataSetItemType(model: $0.key, elements: $0.value)
            }.sorted { lhs, rhs in
                lhs.model.joined() < rhs.model.joined()
            }

            await screen?.onNewDataReceived(oldSet: oldSet, newSet: newSet)
        } catch {
            await screen?.onNewDataError(error)
        }
    }

    func numberOfItemsInSection(_ section: Int) -> Int {
        newSet[section].elements.count
    }

    var numberOfSections: Int {
        newSet.count
    }

    func data(for indexPath: IndexPath) -> DataSetItemType? {
        newSet[
            safe: indexPath.section
        ]
    }

    func data(for indexPath: IndexPath) -> Book? {
        data(for: indexPath)?.elements.lazy[
            safe: indexPath.item
        ]
    }

    func data(for indexPath: IndexPath) -> VolumeInfo? {
        data(for: indexPath)?.elements.lazy.compactMap(\.volumeInfo)[
            safe: indexPath.item
        ]
    }

    func indexPath(for book: Book) -> IndexPath? {
        newSet.enumerated().lazy.compactMap { sectionIndex, section in
            section.elements.enumerated().lazy.compactMap { itemIndex, currentBook in
                currentBook.id == book.id ? IndexPath(item: itemIndex, section: sectionIndex) : nil
            }.first
        }.first
    }

    func on(newSet: DataSetType) {
        self.newSet = newSet
    }
}

extension Book: Differentiable {
    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: Book) -> Bool {
        source.id == id
    }
}

extension DataSetKeyType: Differentiable {}

extension ArraySection: @unchecked @retroactive Sendable {}
