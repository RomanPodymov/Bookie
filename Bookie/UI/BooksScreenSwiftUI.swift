//
//  BooksScreenSwiftUI.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import OrderedCollections
import SwiftUI

extension Book: Identifiable {}

final class BooksScreenRootViewState: ObservableObject {
    @Published var data: DataSetType = .init()
}

extension DataSetItemType: @retroactive Identifiable {
    public var id: DataSetKeyType {
        differenceIdentifier
    }
}

struct BooksScreenRootView: View {
    @ObservedObject var state = BooksScreenRootViewState()
    @Binding private var selectedBook: Book?
    @Binding private var searchText: String
    @State private var showCancelButton = false

    init(state: BooksScreenRootViewState = BooksScreenRootViewState(), selectedBook: Binding<Book?>, searchText: Binding<String>) {
        self.state = state
        _selectedBook = selectedBook
        _searchText = searchText
    }

    var body: some View {
        VStack {
            HStack {
                TextField("", text: $searchText, onEditingChanged: { _ in
                    self.showCancelButton = true
                }, onCommit: {})
                    .padding(.leading, 20)
                if showCancelButton {
                    Button(L10n.BooksScreen.Button.cancel) {
                        self.searchText = ""
                        self.showCancelButton = false
                    }
                    .padding(.trailing, 20)
                }
            }
            List {
                ForEach(state.data) { section in
                    Section(header: Text(section.model.joined(separator: ", "))) {
                        ForEach(section.elements) { book in
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
}

final class BooksScreenSwiftUI: UIHostingController<BooksScreenRootView>, AnyBooksScreen {
    private var viewModel: BooksViewModel!

    init(searchText: String, previousBook: Book?) {
        let selectedBook: Binding<Book?> = .init(get: {
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
        })
        viewModel = .init(screen: nil, searchText: searchText, previousBook: previousBook)
        let searchTextBinding: Binding<String> = .init(get: { [viewModel] in
            viewModel?.searchText.value ?? ""
        }, set: { [viewModel] in
            viewModel?.searchText.send($0)
        })
        super.init(
            rootView: BooksScreenRootView(
                selectedBook: selectedBook,
                searchText: searchTextBinding
            )
        )
        viewModel.screen = self

        Task { [weak viewModel] in
            await viewModel?.reloadData()
        }
    }

    func onNewDataReceived(oldSet _: DataSetType, newSet: DataSetType) async {
        rootView.state.data = newSet
    }

    func onNewDataError(_: BooksViewModelError) async {}

    func onSearchTextChanged(_: String) async {
        await Task { [weak viewModel] in
            await viewModel?.reloadData()
        }.value
    }

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
    }
}
