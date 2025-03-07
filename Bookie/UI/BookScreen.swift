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

    init(_ volumeInfo: VolumeInfo) {
        super.init(nibName: nil, bundle: nil)
        viewModel = BookViewModel(screen: self, data: volumeInfo)
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
                    string: viewModel.data?.imageLinks?.homeScreenImage
                ) ?? .init(unsafeString: "")
            )
        )

        backButton = .init().then {
            if let image = UIImage(systemName: "arrowshape.backward.fill") {
                $0.setImageForAllStates(image)
            } else {
                $0.setTitleForAllStates(L10n.BookScreen.buttonBack)
            }
            $0.addAction(.init(handler: { _ in
                Task {
                    await dependenciesContainer.resolve(AnyCoordinator.self)?.openHomeScren()
                }
            }), for: .primaryActionTriggered)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.top.equalToSuperview()
            }
        }
        openBookButton = .init().then {
            if let image = UIImage(systemName: "book") {
                $0.setImageForAllStates(image)
            } else {
                $0.setTitleForAllStates(L10n.BookScreen.buttonBack)
            }
            $0.addAction(.init(handler: { _ in
                Task {
                    let stringURL = "ibooks://assetid/2SYhAQAAIAAJ"
                    let url = URL(string: stringURL)
                    await UIApplication.shared.open(url!)
                }
            }), for: .primaryActionTriggered)
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.trailing.top.equalToSuperview()
            }
        }
    }
}

extension BookScreen: AnyBookScreen {}
