//
//  BookCell.swift
//  Bookie
//
//  Created by Roman Podymov on 06/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Fashion
import Reusable
import UIKit

class BookCell: UICollectionViewCell, Reusable {
    private unowned var thumbnailView: UIImageView!
    private unowned var titleLabel: UILabel!
    private unowned var authorLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        thumbnailView = .init(styles: [Style.bookCellThumb]).then {
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.leading.top.equalToSuperview()
                make.width.equalTo(contentView).dividedBy(LayoutParams.BooksScren.thumbImageRatio)
            }
        }

        titleLabel = .init(styles: [Style.titleLabel]).then {
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.trailing.equalToSuperview().inset(LayoutParams.BooksScren.defaultInset)
                make.leading.equalTo(thumbnailView.snp.trailing).inset(-1 * LayoutParams.BooksScren.defaultInset)
            }
        }

        authorLabel = .init(styles: [Style.subtitleLabel]).then {
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).inset(-1 * LayoutParams.BooksScren.smallerInset)
                make.leading.trailing.equalTo(titleLabel)
            }
        }
    }

    func setup(with volumeInfo: VolumeInfo) {
        apply(styles: Style.bookCell)
        thumbnailView.kf.setImage(with: URL(string: volumeInfo.imageLinks?.homeScreenImage ?? ""))
        titleLabel.text = volumeInfo.title
        authorLabel.text = volumeInfo.authors?.reduce("") { result, item in result + item }
    }

    required init?(coder _: NSCoder) {
        nil
    }
}
