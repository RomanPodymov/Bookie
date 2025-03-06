//
//  BookCell.swift
//  Bookie
//
//  Created by Roman Podymov on 06/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Reusable
import UIKit

class BookCell: UICollectionViewCell, Reusable {
    private unowned var thumbnailView: UIImageView!
    private unowned var titleLabel: UILabel!
    private unowned var authorLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        thumbnailView = .init().then {
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.bottom.leading.top.equalToSuperview()
            }
        }

        titleLabel = .init().then {
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.trailing.equalToSuperview()
                make.leading.equalTo(thumbnailView.snp.trailing)
            }
        }

        authorLabel = .init().then {
            contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom)
                make.leading.equalTo(titleLabel)
            }
        }
    }

    func setup(with volumeInfo: VolumeInfo) {
        thumbnailView.kf.setImage(with: URL(string: volumeInfo.imageLinks?.homeScreenImage ?? ""))
        titleLabel.text = volumeInfo.title
        authorLabel.text = volumeInfo.authors?.reduce("") { result, item in result + item }
    }

    required init?(coder _: NSCoder) {
        nil
    }
}

private extension ImageLinks {
    var homeScreenImage: String? {
        let paths: Set<KeyPath<ImageLinks, String?>> = [
            \.smallThumbnail,
            \.thumbnail,
            \.small,
            \.medium,
            \.large,
            \.extraLarge,
        ]
        return paths.lazy.compactMap { self[keyPath: $0] }.first
    }
}
