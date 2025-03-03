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
    }

    func openDetailScreen() {}
}
