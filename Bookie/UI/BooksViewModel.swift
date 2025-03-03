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

class BooksViewModel {
    unowned var screen: AnyBooksScreen!

    var searchText: String?
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
            let newSet = books.items
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
