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

    var string: String {
        rawValue
    }
}

final class MainStylesheet: Stylesheet {
    func define() {
        register(Style.titleLabel) { (label: UILabel) in
            Task { @MainActor in
                label.textColor = .red
            }
        }

        register(Style.subtitleLabel) { (label: UILabel) in
            Task { @MainActor in
                label.textColor = .white
            }
        }

        register(Style.loadingView) { (loadingView: UIView) in
            Task { @MainActor in
                loadingView.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            }
        }
    }
}
