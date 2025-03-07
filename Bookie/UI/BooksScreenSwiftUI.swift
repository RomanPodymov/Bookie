//
//  BooksScreenSwiftUI.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import SwiftUI

// TODO: SwiftUI version
struct BooksScreenRootView: View {
    var body: some View {
        Text("Hello")
    }
}

final class BooksScreenSwiftUI: UIHostingController<BooksScreenRootView>, AnyBooksScreen {
    func onNewDataReceived(oldSet _: DataSetType, newSet _: DataSetType) async {}

    func onNewDataError(_: BooksViewModelError) async {}

    func onSearchTextChanged(_: String) async {}

    init() {
        super.init(rootView: BooksScreenRootView())
    }

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
    }

    func onNewDataReceived() async {}
}
