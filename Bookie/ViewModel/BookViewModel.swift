//
//  BookViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import JobInterviewAssignmentKit
import UIKit

protocol AnyBookScreen: Screen {
    @MainActor
    init(_ data: Book?)
}

class BookViewModel<BookScreenType: AnyObject & AnyBookScreen>: BasicViewModel<BookScreenType> {
    var data: Book?

    init(screen: BookScreenType!, data: Book? = nil) {
        self.data = data
        super.init()
        self.screen = screen
    }

    @MainActor
    func openBook() async {
        await UIApplication.shared.open(
            URL(
                unsafeString: "https://play.google.com/store/books/details?id=" + (data?.id ?? "")
            )
        )
    }
}
