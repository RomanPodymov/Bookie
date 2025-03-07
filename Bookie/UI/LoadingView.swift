//
//  LoadingView.swift
//  Bookie
//
//  Created by Roman Podymov on 07/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

final class LoadingView: UIView {
    private unowned var activityIndicatorView: NVActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        activityIndicatorView = .init(frame: .zero).then {
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(32)
                make.height.equalTo(32)
            }
        }
    }

    required init?(coder _: NSCoder) {
        nil
    }

    func show() {
        isHidden = false
        activityIndicatorView.startAnimating()
    }

    func hide() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }
}
