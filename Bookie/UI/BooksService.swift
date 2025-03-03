//
//  BooksService.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Foundation
import Moya

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
