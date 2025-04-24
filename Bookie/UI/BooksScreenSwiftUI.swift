//
//  BooksScreenSwiftUI.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import CombineMoya
import SwiftUI

extension Book: Identifiable {}

struct SectionStuff: Identifiable {
    var section: String
    var items: [Book]

    var id: String {
        section
    }
}

final class ContentViewState: ObservableObject {
    @Published var data: [SectionStuff] = .init()
}

struct BooksScreenRootView: View {
    @ObservedObject var data = ContentViewState()

    var body: some View {
        List {
            ForEach(data.data) { section in
                Section(header: Text(section.section)) {
                    ForEach(section.items) { book in
                        Text(book.volumeInfo.title)
                    }
                }
            }
        }
    }
}

final class BooksScreenSwiftUI: UIHostingController<BooksScreenRootView>, AnyBooksScreen {
    private var viewModel: BooksViewModel!

    init(searchText: String, previousBook: Book?) {
        super.init(rootView: BooksScreenRootView())
        viewModel = .init(screen: self, searchText: searchText, previousBook: previousBook)

        Task { [weak viewModel] in
            await viewModel?.reloadData()
        }
    }

    func onNewDataReceived(oldSet _: DataSetType, newSet: DataSetType) async {
        rootView.data.data = newSet.map {
            .init(
                section: $0.differenceIdentifier.joined(separator: ", "),
                items: $0.elements
            )
        }
    }

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
