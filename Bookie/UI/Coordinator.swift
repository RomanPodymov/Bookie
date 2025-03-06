//
//  Coordinator.swift
//  Bookie
//
//  Created by Roman Podymov on 02/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import UIKit

class Coordinator: AnyCoordinator {
    private var window: UIWindow?

    func set(window: UIWindow) {
        self.window = window
    }

    func openHomeScren() async {
        await MainActor.run { [weak window] in
            window?.rootViewController = BooksScreen()
        }
        await animateScrenChange()
    }

    func openDetailScreen(book: Book) async {
        await MainActor.run { [weak window] in
            window?.rootViewController = BookScreen(book: book)
        }
        await animateScrenChange()
    }

    private func animateScrenChange() async {
        guard let window else {
            return
        }
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.3
        await UIView.transition(with: window, duration: duration, options: options, animations: {})
    }
}

private extension UIView {
    @discardableResult
    class func transition(
        with view: UIView,
        duration: TimeInterval,
        options: UIView.AnimationOptions = [],
        animations: (() -> Void)?
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            Self.transition(
                with: view,
                duration: duration,
                options: options,
                animations: animations
            ) {
                continuation.resume(returning: $0)
            }
        }
    }
}
