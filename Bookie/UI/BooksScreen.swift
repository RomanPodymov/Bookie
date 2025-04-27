//
//  BooksScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import DifferenceKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended
import Reusable
import SwiftAlertView
import UICollectionViewLeftAlignedLayout
import UIKit

class BooksScreenView: UIView {}

final class BooksScreen: UIViewController {
    private unowned var searchBar: UISearchBar!
    private unowned var rootView: UICollectionView!
    private unowned var loadingView: LoadingView!

    private var viewModel: BooksViewModel!

    init(searchText: String, previousBook: Book?) {
        super.init(nibName: nil, bundle: nil)
        viewModel = BooksViewModel(screen: self, searchText: searchText, previousBook: previousBook)
    }

    required init?(coder _: NSCoder) {
        nil
    }

    override func loadView() {
        view = BooksScreenView(styles: [Style.booksScreenView])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar = .init().then {
            $0.text = viewModel.searchText.value
            $0.delegate = self
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperview()
            }
        }

        rootView = .init(frame: .zero, collectionViewLayout: UICollectionViewLeftAlignedLayout()).then {
            $0.apply(styles: Style.booksScreenRootView)
            $0.dataSource = self
            $0.delegate = self
            let collectionViewLayout = $0.collectionViewLayout as? UICollectionViewFlowLayout
            collectionViewLayout?.minimumLineSpacing = LayoutParams.BooksScren.smallerInset
            collectionViewLayout?.minimumInteritemSpacing = LayoutParams.BooksScren.smallerInset
            collectionViewLayout?.itemSize = LayoutParams.BooksScren.itemSize
            collectionViewLayout?.headerReferenceSize = LayoutParams.BooksScren.sectionHeaderSize
            $0.register(
                supplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                withClass: BookSectionHeader.self
            )
            $0.register(cellType: BookCell.self)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.bottom.trailing.equalToSuperview().inset(LayoutParams.BooksScren.defaultInset)
                make.top.equalTo(searchBar.snp.bottom)
            }
        }

        loadingView = .init(styles: [Style.loadingView]).then {
            $0.hide()
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        loadingView.show()
        viewModel.ready()
    }
}

extension BooksScreen: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItemsInSection(section)
    }

    func numberOfSections(in _: UICollectionView) -> Int {
        viewModel.numberOfSections
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: BookCell.self)

        viewModel.data(for: indexPath).map {
            cell.setup(with: $0)
        }

        return cell
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

        viewModel.data(for: indexPath).map {
            header.setup(with: $0)
        }

        return header
    }
}

extension BooksScreen: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Task { [weak viewModel] in
            let searchText = viewModel?.searchText.value ?? ""
            await viewModel?.data(for: indexPath).mapAsync {
                await dependenciesContainer.resolve(AnyCoordinator.self)?.openDetailScreen($0, searchText: searchText)
            }
        }
    }
}

extension BooksScreen: AnyBooksScreen {
    func onNewDataReceived(oldSet: DataSetType, newSet: DataSetType) async {
        await MainActor.run { [weak viewModel] in
            rootView.reload(using: StagedChangeset(source: oldSet, target: newSet)) { [weak viewModel] collection in
                viewModel?.on(newSet: collection)
                if let previousBook = viewModel?.previousBook, let indexPath = viewModel?.indexPath(for: previousBook) {
                    viewModel?.previousBook = nil
                    DispatchQueue.main.async {
                        self.rootView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
                    }
                }
            }
        }
        loadingView?.hide()
    }

    func onNewDataError(_: BooksViewModelError) async {
        loadingView?.hide()
        SwiftAlertView.show(
            title: L10n.BooksScreen.ErrorLoadingData.title,
            buttonTitles: [L10n.BooksScreen.ErrorLoadingData.buttonOk]
        )
    }

    func onSearchTextChanged(_ searchText: String) async {
        await MainActor.run { [weak searchBar] in
            searchBar?.text = searchText
        }
        await Task { [weak viewModel] in
            await viewModel?.reloadData()
        }.value
    }
}

extension BooksScreen: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange _: String) {
        viewModel.searchText.send(searchBar.text ?? "")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
