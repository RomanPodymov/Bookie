//
//  MainStylesheet.swift
//  Bookie
//
//  Created by Roman Podymov on 07/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Fashion
import UIKit

struct LayoutParams {
    enum BooksScren {
        static let defaultInset = CGFloat(20)
        static let smallerInset = CGFloat(10)
        static let sectionHeaderSize = CGSize(width: 300, height: 80)
        static let itemSize = CGSize(width: 300, height: 250)
        static let thumbImageRatio = CGFloat(3)
    }

    enum BookScreen {
        static let defaultInset = CGFloat(20)
    }
}

enum AppColors {
    static let textColor = UIColor.black
    static let backgroundColor = UIColor.white
    static let metadataBackgroundColor = backgroundColor.withAlphaComponent(0.5)
}

enum Style: String, StringConvertible {
    case headerLabel
    case titleLabel
    case subtitleLabel
    case loadingView
    case booksScreenView
    case booksScreenRootView
    case bookSectionHeader
    case bookCell
    case bookCellThumb
    case bookScreenMetadataView

    var string: String {
        rawValue
    }
}

final class MainStylesheet: Stylesheet {
    func define() {
        registerLabels()

        register(Style.loadingView) { (loadingView: UIView) in
            Task { @MainActor in
                loadingView.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            }
        }

        let backgroundColor = AppColors.backgroundColor

        register(Style.booksScreenView) { (booksScreenView: UIView) in
            Task { @MainActor in
                booksScreenView.backgroundColor = backgroundColor
            }
        }

        register(Style.booksScreenRootView) { (view: UICollectionView) in
            Task { @MainActor in
                view.backgroundColor = backgroundColor
            }
        }

        register(Style.bookSectionHeader) { (header: BookSectionHeader) in
            Task { @MainActor in
                header.backgroundColor = backgroundColor
            }
        }

        register(Style.bookCell) { (cell: BookCell) in
            Task { @MainActor in
                cell.backgroundColor = backgroundColor
            }
        }

        register(Style.bookCellThumb) { (thumb: UIImageView) in
            Task { @MainActor in
                thumb.addShadow(ofColor: UIColor.black)
            }
        }

        register(Style.bookScreenMetadataView) { (view: UIView) in
            Task { @MainActor in
                view.backgroundColor = AppColors.metadataBackgroundColor
            }
        }
    }

    private func registerLabels() {
        let textColor = AppColors.textColor

        register(Style.headerLabel) { (label: UILabel) in
            Task { @MainActor in
                label.font = UIFont.boldSystemFont(ofSize: 24)
                label.textColor = textColor
            }
        }

        register(Style.titleLabel) { (label: UILabel) in
            Task { @MainActor in
                label.font = UIFont.boldSystemFont(ofSize: 20)
                label.textColor = textColor
            }
        }

        register(Style.subtitleLabel) { (label: UILabel) in
            Task { @MainActor in
                label.font = UIFont.systemFont(ofSize: 18)
                label.textColor = textColor
            }
        }
    }
}
