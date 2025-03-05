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

protocol AnyBooksScreen: AnyObject {
    func onNewDataReceived(oldSet: [Book], newSet: [Book]) async
}

enum BookLanguage: String {
    case en
    case cs
}

class BooksViewModel {
    unowned var screen: AnyBooksScreen!

    var searchText: String? = "peter"
    var allowedLanguages: [BookLanguage] = [.cs]
    private var data: BookResponse?
    var oldSet: [Book] = []
    var newSet: [Book] = []

    init(screen: AnyBooksScreen!, data: BookResponse? = nil) {
        self.screen = screen
        self.data = data
    }

    func reloadData() async {
        let provider = MoyaProvider<BooksService>()
        do {
            guard let response = try await provider.requestPublisher(.volumes(query: searchText)).values.first(where: { _ in true }) else {
                return
            }
            let books = try JSONDecoder().decode(BookResponse.self, from: response.data)
            data = books
            oldSet = newSet
            let newSet = books.items.filter { book in
                allowedLanguages.contains(
                    book.volumeInfo.language.flatMap { BookLanguage(rawValue: $0) } ?? .en
                )
            }
            await screen?.onNewDataReceived(oldSet: oldSet, newSet: newSet)
        } catch {}
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
