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

class BooksViewModel {
    unowned var screen: BooksScreen!

    var data: BookResponse?

    init(screen: BooksScreen!, data: BookResponse? = nil) {
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

enum BooksService {
    case volumes(query: String)
}

extension BooksService: TargetType {
    var baseURL: URL {
        URL(string: "https://www.googleapis.com")!
    }

    var path: String {
        "books/v1/volumes"
    }

    var method: Moya.Method {
        .get
    }

    var task: Moya.Task {
        switch self {
        case let .volumes(query):
            .requestParameters(parameters: ["q": query], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
