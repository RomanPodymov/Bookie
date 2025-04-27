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
            if let detailScreenImage = data?.volumeInfo.imageLinks?.detailScreenImage {
                KFImage(URL(
                    unsafeString: detailScreenImage
                ))
                .resizable()
                .aspectRatio(contentMode: .fill)
            }
            VStack {
                HStack {
                    Button {
                        backPressed = true
                    } label: {
                        Image(systemName: "arrowshape.backward.fill")
                    }
                    Spacer()
                }
                .padding(.leading, LayoutParams.BooksScren.defaultInset)
                .padding(.top, LayoutParams.BooksScren.defaultInset)
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text(data?.volumeInfo.title ?? "")
                            .foregroundStyle(Color(AppColors.textColor))
                        Text(data?.volumeInfo.authors?.joined(separator: ", ") ?? "")
                            .foregroundStyle(Color(AppColors.textColor))
                        Text(data?.volumeInfo.publishedDate ?? "")
                            .foregroundStyle(Color(AppColors.textColor))
                        Text(data?.volumeInfo.description ?? "")
                            .foregroundStyle(Color(AppColors.textColor))
                    }
                    .background(Color(AppColors.metadataBackgroundColor))
                    Spacer()
                }
                .padding(.leading, LayoutParams.BooksScren.defaultInset)
                .padding(.bottom, LayoutParams.BooksScren.defaultInset)
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
        // viewModel.screen = self
    }

    @MainActor @preconcurrency dynamic required init?(coder _: NSCoder) {
        nil
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
}
