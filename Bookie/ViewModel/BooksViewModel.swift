//
//  BooksViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 02/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Combine
import DifferenceKit
import Foundation
import JobInterviewAssignmentKit
import OrderedCollections

protocol AnyBooksScreen: Screen, Sendable {
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

final class BooksViewModel<BooksScreenType: AnyObject & AnyBooksScreen>: BasicViewModel<BooksScreenType> {
    let searchText: CurrentValueSubject<String, Never>
    var previousBook: Book?

    var allowedLanguages: Set<BookLanguage> = [.cs, .en]
    private var data: BookResponse?
    private var oldSet: DataSetType = .init()
    private var newSet: DataSetType = .init()
    private var cancellables = Set<AnyCancellable>()

    init(screen: BooksScreenType!, searchText: String, previousBook: Book?, data: BookResponse? = nil) {
        self.searchText = .init(searchText)
        self.previousBook = previousBook
        self.data = data
        super.init()
        self.screen = screen
    }

    override func reloadData() async {
        await super.reloadData()
        guard let source = dependenciesContainer.resolve(RemoteDataSource.self),
              let localSource = dependenciesContainer.resolve(LocalDataSource.self)
        else {
            return
        }
        do {
            let books: BookResponse
            if let booksRemote = try? await source.search(text: searchText.value) {
                books = booksRemote
                try await localSource.save(books: books.items)
            } else {
                books = try await localSource.search(text: searchText.value)
            }

            data = books
            oldSet = newSet

            await screen?.onNewDataReceived(oldSet: oldSet, newSet: createSet(from: books))
        } catch {
            await screen?.onNewDataError(error)
        }
    }

    override func ready() {
        super.ready()
        searchText.removeDuplicates().sink { [weak screen = self.screen] text in
            _Concurrency.Task { [weak screen] in
                await screen?.onSearchTextChanged(text)
            }
        }.store(in: &cancellables)
    }

    private func createSet(from books: BookResponse) -> DataSetType {
        let newSetFiltered = books.items.filter { book in
            guard let language = book.volumeInfo.language.flatMap({ BookLanguage(rawValue: $0) }) else {
                return false
            }
            return allowedLanguages.contains(language)
        }
        return [DataSetKeyType: [Book]](grouping: newSetFiltered, by: {
            $0.volumeInfo.categories.map { .init($0) } ?? .init()
        }).mapValues {
            $0.sorted(by: \.volumeInfo.title)
        }.map {
            DataSetItemType(model: $0.key, elements: $0.value)
        }.sorted { lhs, rhs in
            lhs.model.joined() < rhs.model.joined()
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
