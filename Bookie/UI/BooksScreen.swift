//
//  BooksScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Kingfisher
import Reusable
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
        viewModel.data?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let result = collectionView.dequeueReusableCell(for: indexPath, cellType: BookCell.self)
        let data = viewModel.data?.items.lazy.compactMap {
            $0.volumeInfo.imageLinks?.thumbnail
        }[safe: indexPath.item]
        result.bookPhotoView.kf.setImage(with: URL(string: data ?? ""))
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

extension BooksScreen: AnyBooksScreen {
    func onNewDataReceived() async {
        await MainActor.run {
            rootView.reloadData()
        }
    }
}

struct BooksScreenRootView: View {
    var body: some View {
        Text("Hello")
    }
}

final class BooksScreenSwiftUI: UIHostingController<BooksScreenRootView>, AnyBooksScreen {
    init() {
        super.init(rootView: BooksScreenRootView())
    }

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
    }

    func onNewDataReceived() async {}
}

final class BooksScreen: UIViewController {
    private unowned var rootView: UICollectionView!

    private lazy var viewModel = BooksViewModel(screen: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
            $0.dataSource = self
            $0.delegate = self
            $0.register(cellType: BookCell.self)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        view.backgroundColor = .green

        Task { [weak viewModel] in
            await viewModel?.reloadData()
        }
    }
}
