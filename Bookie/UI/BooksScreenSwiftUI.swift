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
    let section: DataSetKeyType
    let items: [Book]

    var id: DataSetKeyType {
        section
    }
}

final class BooksScreenRootViewState: ObservableObject {
    @Published var data: [SectionStuff] = .init()
}

struct BooksScreenRootView: View {
    @ObservedObject var state = BooksScreenRootViewState()
    @Binding var selectedBook: Book?

    init(state: BooksScreenRootViewState = BooksScreenRootViewState(), selectedBook: Binding<Book?>) {
        self.state = state
        _selectedBook = selectedBook
    }

    var body: some View {
        List {
            ForEach(state.data) { section in
                Section(header: Text(section.section.joined(separator: ", "))) {
                    ForEach(section.items) { book in
                        Button(action: {
                            selectedBook = book
                        }, label: {
                            Text(book.volumeInfo.title)
                        })
                    }
                }
            }
        }
    }
}

final class BooksScreenSwiftUI: UIHostingController<BooksScreenRootView>, AnyBooksScreen {
    private var viewModel: BooksViewModel!

    init(searchText: String, previousBook: Book?) {
        super.init(rootView: BooksScreenRootView(selectedBook: .init(get: {
            previousBook
        }, set: { book in
            guard let book else {
                return
            }
            Task {
                await dependenciesContainer.resolve(
                    AnyCoordinator.self
                )?.openDetailScreen(book, searchText: searchText)
            }
        })))
        viewModel = .init(screen: self, searchText: searchText, previousBook: previousBook)

        Task { [weak viewModel] in
            await viewModel?.reloadData()
        }
    }

    func onNewDataReceived(oldSet _: DataSetType, newSet: DataSetType) async {
        rootView.state.data = newSet.map {
            .init(
                section: $0.differenceIdentifier,
                items: $0.elements
            )
        }
    }

    func onNewDataError(_: BooksViewModelError) async {}

    func onSearchTextChanged(_: String) async {}

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
    }

    func onNewDataReceived() async {}
}
