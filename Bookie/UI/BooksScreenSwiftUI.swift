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
    @ObservedObject var state: BooksScreenRootViewState
    @Binding private var selectedBook: Book?
    @Binding private var searchText: String
    @State private var showCancelButton = false

    init(
        state: BooksScreenRootViewState = BooksScreenRootViewState(),
        selectedBook: Binding<Book?>,
        searchText: Binding<String>
    ) {
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
                    .padding(.leading, LayoutParams.BooksScren.defaultInset)
                    .foregroundStyle(Color(AppColors.textColor))
                if showCancelButton {
                    Button(L10n.BooksScreen.Button.cancel) {
                        self.searchText = ""
                        self.showCancelButton = false
                    }
                    .foregroundStyle(Color(AppColors.textColor))
                    .padding(.trailing, LayoutParams.BooksScren.defaultInset)
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
                                    .foregroundStyle(Color(AppColors.textColor))
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
        viewModel = .init(screen: nil, searchText: searchText, previousBook: previousBook)
        super.init(
            rootView: BooksScreenRootView(
                selectedBook: Self.selectedBook(searchText: searchText, previousBook: previousBook),
                searchText: Self.searchTextBinding(viewModel: viewModel)
            )
        )
        // viewModel.screen = self

        Task { [weak viewModel] in
            await viewModel?.reloadData()
        }
    }

    private static func selectedBook(searchText: String, previousBook: Book?) -> Binding<Book?> {
        .init(get: {
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
    }

    private static func searchTextBinding(viewModel: BooksViewModel) -> Binding<String> {
        .init(get: { [weak viewModel] in
            viewModel?.searchText.value ?? ""
        }, set: { [weak viewModel] in
            viewModel?.searchText.send($0)
        })
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
