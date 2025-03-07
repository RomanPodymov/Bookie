//
//  MainStylesheet.swift
//  Bookie
//
//  Created by Roman Podymov on 07/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Fashion
import UIKit

enum Style: String, StringConvertible {
    case titleLabel
    case subtitleLabel
    case loadingView
    case booksScreenView
    case booksScreenRootView
    case bookSectionHeader
    case bookCell

    var string: String {
        rawValue
    }
}

final class MainStylesheet: Stylesheet {
    func define() {
        let textColor = UIColor.black

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

        register(Style.loadingView) { (loadingView: UIView) in
            Task { @MainActor in
                loadingView.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            }
        }

        let backgroundColor = UIColor.yellow

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
    }
}
