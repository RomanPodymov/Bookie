//
//  CoordinatorSwiftUI.swift
//  Bookie
//
//  Created by Roman Podymov on 27/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import UIKit

class CoordinatorSwiftUI: Coordinator {
    @MainActor
    override class func createRootScreen(
        searchText: String,
        previousBook: Book?
    ) -> (any AnyBooksScreen & UIViewController) {
        BooksScreenSwiftUI(searchText: searchText, previousBook: previousBook)
    }

    @MainActor
    override class func createDetailScreen(
        _ data: Book
    ) -> (any AnyBookScreen & UIViewController) {
        BookScreenSwiftUI(data)
    }
}
