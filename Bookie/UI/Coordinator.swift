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

            let options: UIView.AnimationOptions = .transitionCrossDissolve
            let duration: TimeInterval = 0.3
            UIView.transition(with: window!, duration: duration, options: options, animations: {}, completion: { _ in })
        }
    }

    func openDetailScreen(book: Book) async {
        await MainActor.run { [weak window] in
            window?.rootViewController = BookScreen(book: book)

            let options: UIView.AnimationOptions = .transitionCrossDissolve
            let duration: TimeInterval = 0.3
            UIView.transition(with: window!, duration: duration, options: options, animations: {}, completion: { _ in })
        }
    }
}
