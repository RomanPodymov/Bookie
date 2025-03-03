//
//  BookScreen.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
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

final class BookScreen: UIViewController {
    private unowned var bookImage: UIImageView!

    private var viewModel: BookViewModel!

    init(book: Book) {
        super.init(nibName: nil, bundle: nil)
        viewModel = BookViewModel(screen: self, data: book)
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
        bookImage.kf.setImage(with: .network(URL(string: viewModel.data!.volumeInfo.imageLinks!.thumbnail) ?? .init(unsafeString: "")))
    }
}

extension BookScreen: AnyBookScreen {}
