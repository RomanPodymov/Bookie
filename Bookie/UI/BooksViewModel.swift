//
//  BooksViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 02/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import CombineMoya
import DifferenceKit
import Foundation
import Moya

protocol AnyBooksScreen: AnyObject, Sendable {
    func onNewDataReceived(oldSet: DataSetType, newSet: DataSetType) async
    func onSearchTextChanged(_ searchText: String) async
}

enum BookLanguage: String {
    // swiftlint:disable identifier_name
    case en
    case cs

    static let `default` = Self.cs
    // swiftlint:enable identifier_name
}

typealias DataSetKeyType = Set<String>
typealias DataSetItemType = ArraySection<DataSetKeyType, Book>
typealias DataSetType = [ArraySection<DataSetKeyType, Book>]

final class BooksViewModel {
    unowned var screen: AnyBooksScreen!

    var searchText: String? {
        didSet {
            _Concurrency.Task.detached { [weak screen, searchText] in
                await screen?.onSearchTextChanged(searchText ?? "")
            }
        }
    }

    var allowedLanguages: Set<BookLanguage> = [.cs, .en]
    private var data: BookResponse?
    private var oldSet: DataSetType = .init()
    private var newSet: DataSetType = .init()

    init(screen: AnyBooksScreen!, searchText: String, data: BookResponse? = nil) {
        self.screen = screen
        self.searchText = searchText
        self.data = data
        _Concurrency.Task.detached { [weak screen, searchText] in
            await screen?.onSearchTextChanged(searchText)
        }
    }

    func reloadData() async {
        let provider = MoyaProvider<BooksService>()
        do {
            guard let response = try await provider.requestPublisher(.volumes(query: searchText)).values.first(
                where: { _ in true }
            ) else {
                return
            }
            let books = try JSONDecoder().decode(BookResponse.self, from: response.data)

            data = books
            oldSet = newSet

            let newSetFiltered = books.items.filter { book in
                allowedLanguages.contains(
                    book.volumeInfo.language.flatMap { BookLanguage(rawValue: $0) } ?? .default
                )
            }
            let newSet = [DataSetKeyType: [Book]](grouping: newSetFiltered, by: {
                $0.volumeInfo.categories.map { .init($0) } ?? .init()
            }).map {
                DataSetItemType(model: $0.key, elements: $0.value)
            }

            await screen?.onNewDataReceived(oldSet: oldSet, newSet: newSet)
        } catch {}
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

    func data(for indexPath: IndexPath) -> VolumeInfo? {
        data(for: indexPath)?.elements.lazy.compactMap(\.volumeInfo)[
            safe: indexPath.item
        ]
    }

    func on(newSet: DataSetType) {
        self.newSet = newSet
    }
}

extension Book: ContentIdentifiable, ContentEquatable {
    var differenceIdentifier: String {
        id
    }

    func isContentEqual(to source: Book) -> Bool {
        source.id == id
    }
}

extension Set<String>: @retroactive ContentIdentifiable, @retroactive ContentEquatable {}

extension ArraySection: @unchecked @retroactive Sendable {}
