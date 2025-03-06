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

protocol AnyBooksScreen: AnyObject {
    func onNewDataReceived(oldSet: DataSetType, newSet: DataSetType) async
}

enum BookLanguage: String {
    // swiftlint:disable identifier_name
    case en
    case cs

    static let `default` = Self.cs
    // swiftlint:enable identifier_name
}

struct BooksForCategory {
    let category: String
    let books: [Book]
}

typealias DataSetItemType = ArraySection<String, Book>
typealias DataSetType = [ArraySection<String, Book>]

class BooksViewModel {
    unowned var screen: AnyBooksScreen!

    var searchText: String? = "King"
    var allowedLanguages: Set<BookLanguage> = [.cs, .en]
    private var data: BookResponse?
    var oldSet: DataSetType = .init()
    var newSet: DataSetType = .init()

    init(screen: AnyBooksScreen!, data: BookResponse? = nil) {
        self.screen = screen
        self.data = data
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
            let newSet = [String: [Book]](grouping: newSetFiltered, by: {
                $0.volumeInfo.categories?.first ?? ""
            }).map {
                DataSetItemType(model: $0.key, elements: $0.value)
            }

            await screen?.onNewDataReceived(oldSet: oldSet, newSet: newSet)
        } catch {}
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

extension String: @retroactive ContentIdentifiable, @retroactive ContentEquatable {}

extension ArraySection: @unchecked @retroactive Sendable {}
