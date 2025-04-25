//
//  BookScreenSwiftUI.swift
//  Bookie
//
//  Created by Roman Podymov on 25/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import SwiftUI

struct BookScreenRootView: View {
    var body: some View {
        Text("Some")
    }
}

final class BookScreenSwiftUI: UIHostingController<BookScreenRootView>, AnyBookScreen {
    init(_: Book?) {
        super.init(rootView: BookScreenRootView())
    }

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
    }
}
