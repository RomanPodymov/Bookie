//
//  Coordinator.swift
//  Bookie
//
//  Created by Roman Podymov on 02/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import UIKit

class Coordinator: AnyCoordinator {
    private weak var window: UIWindow?
    private var searchText = "Karel"

    func set(window: UIWindow) {
        self.window = window
    }

    func openHomeScreen(previousBook: Book?) async {
        await MainActor.run { [weak window, searchText] in
            window?.rootViewController = BooksScreen(searchText: searchText, previousBook: previousBook)
        }
        await animateScrenChange()
    }

    func openDetailScreen(_ data: Book, searchText: String) async {
        self.searchText = searchText
        await MainActor.run { [weak window] in
            window?.rootViewController = BookScreen(data)
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
