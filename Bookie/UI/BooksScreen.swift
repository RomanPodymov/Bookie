//
//  BooksScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Moya
import UIKit

final class BooksScreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .green

        let provider = MoyaProvider<BooksService>()
        provider.request(.volumes) { result in
            switch result {
            case let .success(response):
                print(String(data: response.data, encoding: .utf8))
            case .failure:
                print("")
            }
        }
    }
}

enum BooksService {
    case volumes
}

extension BooksService: TargetType {
    var baseURL: URL {
        URL(string: "https://www.googleapis.com/books/v1")!
    }

    var path: String {
        "volumes"
    }

    var method: Moya.Method {
        .get
    }

    var task: Moya.Task {
        .requestPlain
    }

    var headers: [String: String]? {
        nil
    }
}
