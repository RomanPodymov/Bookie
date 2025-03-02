//
//  BooksScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Moya
import SnapKit
import Then
import UIKit

extension BooksScreen: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        1000
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let result = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        result.backgroundColor = .yellow
        return result
    }
}

extension BooksScreen: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {}
}

extension BooksScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        .init(width: 200, height: 100)
    }
}

final class BooksScreen: UIViewController {
    private unowned var rootView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.dataSource = self
            $0.delegate = self
            $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
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
