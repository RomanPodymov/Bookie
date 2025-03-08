//
//  BookSectionHeader.swift
//  Bookie
//
//  Created by Roman Podymov on 06/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Reusable
import UIKit

class BookSectionHeader: UICollectionReusableView, Reusable {
    private unowned var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        apply(styles: Style.bookSectionHeader)
        label = .init(styles: [Style.headerLabel]).then {
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        nil
    }

    func setup(with data: DataSetItemType) {
        let category = data.model.joined(separator: ",")
        label.text = category.isEmpty ? L10n.BooksScreen.categoryUnknown : category
    }
}
