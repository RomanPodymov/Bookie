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
    func openHomeScren() async
    func openDetailScreen() async
}

let container = {
    let result = Container()
    result.register(AnyCoordinator.self) { _ in
        Coordinator()
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
        setupWindow()
        return true
    }

    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds).then {
            container.resolve(AnyCoordinator.self)?.set(window: $0)
        }
        Task {
            await container.resolve(AnyCoordinator.self)?.openHomeScren()
            window?.makeKeyAndVisible()
        }
    }
}
