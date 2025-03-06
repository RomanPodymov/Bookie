//
//  BooksScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import DifferenceKit
import Reusable
import SHSearchBar
import UIKit

extension BooksScreen: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.newSet[section].elements.count
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        viewModel.newSet.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let result = collectionView.dequeueReusableCell(for: indexPath, cellType: BookCell.self)
        if let data = viewModel.newSet[
            safe: indexPath.section
        ]?.elements.lazy.compactMap(\.volumeInfo)[
            safe: indexPath.item
        ] {
            result.setup(with: data)
        }
        result.backgroundColor = .yellow
        return result
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            for: indexPath,
            viewType: BookSectionHeader.self
        )
        header.label.text = viewModel.newSet[indexPath.section].model
        return header
    }
}

extension BooksScreen: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task {
            let data = viewModel.newSet.lazy.compactMap {
                $0
            }[safe: indexPath.item]
            // await dependenciesContainer.resolve(AnyCoordinator.self)?.openDetailScreen(book: data!)
        }
    }
}

extension BooksScreen: AnyBooksScreen {
    func onNewDataReceived(oldSet: DataSetType, newSet: DataSetType) async {
        await MainActor.run { [weak viewModel] in
            rootView.reload(using: StagedChangeset(source: oldSet, target: newSet)) { [weak viewModel] collection in
                viewModel?.newSet = collection
            }
        }
    }
}

class BookSectionHeader: UICollectionReusableView, Reusable {
    unowned var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .green
        label = .init().then {
            addSubview($0)
            $0.textColor = .black
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        nil
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
            ($0.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = .init(width: 200, height: 100)
            ($0.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = .init(width: 300, height: 200)
            $0.register(
                supplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withClass: BookSectionHeader.self
            )
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
