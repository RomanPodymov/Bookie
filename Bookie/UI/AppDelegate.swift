//
//  AppDelegate.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Fashion
@preconcurrency import Swinject
import Then
import UIKit

protocol AnyCoordinator {
    func set(window: UIWindow)
    func openHomeScreen(previousBook: Book?) async
    func openDetailScreen(_ data: Book, searchText: String) async
}

let dependenciesContainer = {
    let result = Container()
    result.register(AnyCoordinator.self) { _ in
        Coordinator()
    }.inObjectScope(.container)
    result.register(Stylesheet.self) { _ in
        MainStylesheet()
    }.inObjectScope(.container)
    return result
}()

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        dependenciesContainer.resolve(Stylesheet.self).map {
            Fashion.register(stylesheets: [$0])
        }
        setupWindow()
        return true
    }

    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds).then {
            dependenciesContainer.resolve(AnyCoordinator.self)?.set(window: $0)
        }
        Task {
            await dependenciesContainer.resolve(AnyCoordinator.self)?.openHomeScreen(previousBook: nil)
            window?.makeKeyAndVisible()
        }
    }
}
