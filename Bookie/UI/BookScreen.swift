//
//  BookScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Kingfisher
import SnapKit
import SwifterSwift
import UIKit

final class BookScreen: UIViewController {
    private unowned var backButton: UIButton!
    private unowned var openBookButton: UIButton!
    private unowned var bookImage: UIImageView!

    private var viewModel: BookViewModel!

    init(_ data: Book?) {
        super.init(nibName: nil, bundle: nil)
        viewModel = BookViewModel(screen: self, data: data)
    }

    required init?(coder _: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bookImage = .init().then {
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.top.trailing.bottom.equalToSuperview()
            }
        }
        bookImage.kf.setImage(
            with: .network(
                URL(
                    unsafeString: viewModel.data?.volumeInfo.imageLinks?.detailScreenImage ?? ""
                )
            )
        )

        backButton = .init().then {
            if let image = UIImage(systemName: "arrowshape.backward.fill") {
                $0.setImageForAllStates(image)
            } else {
                $0.setTitleForAllStates(L10n.BookScreen.buttonBack)
            }
            $0.addAction(.init(handler: { [weak viewModel] _ in
                Task { [weak viewModel] in
                    await dependenciesContainer.resolve(
                        AnyCoordinator.self
                    )?.openHomeScreen(
                        previousBook: viewModel?.data
                    )
                }
            }), for: .primaryActionTriggered)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.top.equalToSuperview().inset(LayoutParams.BookScreen.defaultInset)
            }
        }
        openBookButton = .init().then {
            if let image = UIImage(systemName: "book") {
                $0.setImageForAllStates(image)
            } else {
                $0.setTitleForAllStates(L10n.BookScreen.buttonBack)
            }
            $0.addAction(.init(handler: { [weak viewModel] _ in
                Task { [weak viewModel] in
                    await viewModel?.openBook()
                }
            }), for: .primaryActionTriggered)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.trailing.top.equalToSuperview().inset(LayoutParams.BookScreen.defaultInset)
            }
        }
    }
}

extension BookScreen: AnyBookScreen {}
