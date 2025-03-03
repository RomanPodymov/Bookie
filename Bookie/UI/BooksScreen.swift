//
//  BooksScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import DifferenceKit
import Kingfisher
import Reusable
import SHSearchBar
import SnapKit
import SwifterSwift
import SwiftUI
import Then
import UIKit

class BookCell: UICollectionViewCell, Reusable {
    unowned var bookPhotoView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        bookPhotoView = UIImageView().then {
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }
}

extension BooksScreen: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        viewModel.newSet.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let result = collectionView.dequeueReusableCell(for: indexPath, cellType: BookCell.self)
        let data = viewModel.newSet.lazy.compactMap {
            $0.volumeInfo.imageLinks?.thumbnail
        }[safe: indexPath.item]
        result.bookPhotoView.kf.setImage(with: URL(string: data ?? ""))
        result.backgroundColor = .yellow
        return result
    }
}

extension BooksScreen: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            let data = viewModel.newSet.lazy.compactMap {
                $0
            }[safe: indexPath.item]
            await dependenciesContainer.resolve(AnyCoordinator.self)?.openDetailScreen(book: data!)
        }
    }
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

extension BooksScreen: AnyBooksScreen {
    func onNewDataReceived(oldSet: [Book], newSet: [Book]) async {
        await MainActor.run {
            rootView.reload(using: StagedChangeset(source: oldSet, target: newSet)) { [weak viewModel] collection in
                viewModel?.newSet = collection
            }
        }
    }
}

final class BooksScreen: UIViewController {
    private unowned var searchBar: SHSearchBar!
    private unowned var rootView: UICollectionView!

    private lazy var viewModel = BooksViewModel(screen: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = .init(config: .init()).then {
            $0.delegate = self
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperview()
            }
        }

        rootView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: BookCell.self)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview()
                make.top.equalTo(searchBar.snp.bottom)
            }
        }

        view.backgroundColor = .green

        Task { [weak viewModel] in
            await viewModel?.reloadData()
        }
    }
}

extension BooksScreen: @preconcurrency SHSearchBarDelegate {
    func searchBar(_ searchBar: SHSearchBar, textDidChange _: String) {
        viewModel.searchText = searchBar.text
        Task { [weak viewModel] in
            await viewModel?.reloadData()
        }
    }
}
