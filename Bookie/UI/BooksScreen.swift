//
//  BooksScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Moya
import Then
import UIKit
import SnapKit

extension BooksScreen: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
}

extension BooksScreen: UICollectionViewDelegate {
    
}

final class BooksScreen: UIViewController {
    private unowned var rootView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView = UICollectionView().then {
            $0.dataSource = self
            $0.delegate = self
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        view.backgroundColor = .green

        let provider = MoyaProvider<BooksService>()
        provider.request(.volumes(query: "flowers")) { result in
            switch result {
            case let .success(response):
                do {
                    let books = try JSONDecoder().decode(BookResponse.self, from: response.data)
                    for book in books.items {
                        print(book.volumeInfo.description)
                    }
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
