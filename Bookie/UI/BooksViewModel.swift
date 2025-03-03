//
//  BooksViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 02/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Combine
import CombineMoya
import Foundation
import Moya

protocol AnyBooksScreen: AnyObject {
    func onNewDataReceived() async
}

class BooksViewModel {
    unowned var screen: AnyBooksScreen!

    var data: BookResponse?

    init(screen: AnyBooksScreen!, data: BookResponse? = nil) {
        self.screen = screen
        self.data = data
    }

    func reloadData() async {
        let provider = MoyaProvider<BooksService>()
        do {
            guard let response = try await provider.requestPublisher(.volumes(query: "flowers")).values.first(where: { _ in true }) else {
                return
            }
            let books = try JSONDecoder().decode(BookResponse.self, from: response.data)
            data = books
            await screen?.onNewDataReceived()
        } catch {}
    }
}
