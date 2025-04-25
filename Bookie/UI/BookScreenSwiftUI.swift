//
//  BookScreenSwiftUI.swift
//  Bookie
//
//  Created by Roman Podymov on 25/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Kingfisher
import SwiftUI

struct BookScreenRootView: View {
    @Binding var backPressed: Bool
    @State var data: Book?

    var body: some View {
        ZStack {
            KFImage(URL(
                unsafeString: data?.volumeInfo.imageLinks?.detailScreenImage ?? ""
            ))
            Button {
                backPressed = true
            } label: {
                Image(systemName: "arrowshape.backward.fill")
            }
            VStack {
                Text(data?.volumeInfo.title ?? "")
            }
        }
    }
}

final class BookScreenSwiftUI: UIHostingController<BookScreenRootView>, AnyBookScreen {
    private var viewModel: BookViewModel!

    init(_ data: Book?) {
        viewModel = BookViewModel(screen: nil, data: data)
        super.init(
            rootView: BookScreenRootView(
                backPressed: Self.backPressedBinding(viewModel: viewModel),
                data: data
            )
        )
        viewModel.screen = self
    }

    private static func backPressedBinding(viewModel: BookViewModel) -> Binding<Bool> {
        .init(get: {
            false
        }, set: { _ in
            Task { [weak viewModel] in
                await dependenciesContainer.resolve(
                    AnyCoordinator.self
                )?.openHomeScreen(
                    previousBook: viewModel?.data
                )
            }
        })
    }

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
    }
}
