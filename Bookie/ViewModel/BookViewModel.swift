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

class BookViewModel: BasicViewModel<BookScreen> {
    var data: Book?

    init(screen: BookScreen!, data: Book? = nil) {
        super.init(screen: screen)
        self.data = data
    }

    required init(screen: ScreenType) {
        super.init(screen: screen)
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
