//
//  BooksViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 02/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Foundation
import Moya

class BooksViewModel {
    unowned var screen: BooksScreen!

    var data: BookResponse?

    init(screen: BooksScreen!, data: BookResponse? = nil) {
        self.screen = screen
        self.data = data
    }

    func reloadData() {
        let provider = MoyaProvider<BooksService>()
        provider.request(.volumes(query: "flowers")) { [weak self] result in
            switch result {
            case let .success(response):
                do {
                    let books = try JSONDecoder().decode(BookResponse.self, from: response.data)
                    self?.data = books
                    self?.screen.onNewDataReceived()
                } catch {
                    print(error)
                }
            case .failure:
                print("")
            }
        }
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
