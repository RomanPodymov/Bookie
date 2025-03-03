//
//  BooksScreenSwiftUI.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Kingfisher
import Reusable
import SnapKit
import SwifterSwift
import SwiftUI

struct BooksScreenRootView: View {
    var body: some View {
        Text("Hello")
    }
}

final class BooksScreenSwiftUI: UIHostingController<BooksScreenRootView>, AnyBooksScreen {
    init() {
        super.init(rootView: BooksScreenRootView())
    }

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
    }

    func onNewDataReceived() async {}
}
