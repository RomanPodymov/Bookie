//
//  DI.swift
//  Bookie
//
//  Created by Roman Podymov on 27/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Fashion
import SwiftData
@preconcurrency import Swinject
import UIKit

protocol AnyCoordinator {
    func set(window: UIWindow)
    func openHomeScreen(previousBook: Book?) async
    func openDetailScreen(_ data: Book, searchText: String) async
}

protocol RemoteDataSource {
    func search(text: String) async throws (BooksViewModelError) -> BookResponse
}

protocol LocalDataSource: RemoteDataSource {
    func save(books: [Book]) async throws (BooksViewModelError)
}

let dependenciesContainer = {
    let result = Container()
    let objectScope: ObjectScope = .container
    result.register(AnyCoordinator.self) { _ in
        CoordinatorSwiftUI()
    }.inObjectScope(objectScope)
    result.register(Stylesheet.self) { _ in
        MainStylesheet()
    }.inObjectScope(objectScope)
    result.register(RemoteDataSource.self) { _ in
        GoogleRemoteDataSource()
    }.inObjectScope(objectScope)
    result.register(LocalDataSource.self) { _ in
        if #available(iOS 17, *), let container = {
            let configuration = ModelConfiguration(for: BookSwiftData.self)
            let schema = Schema([BookSwiftData.self])
            return try? ModelContainer(for: schema, configurations: [configuration])
        }() {
            return SwiftDataSource(modelContainer: container)
        } else {
            return RealmDataSource()
        }
    }
    return result
}()
