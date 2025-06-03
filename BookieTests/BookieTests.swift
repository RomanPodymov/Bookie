//
//  BookieTests.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

@testable import BookieApp
import Swinject
import XCTest

extension Book: @retroactive Equatable {
    public static func == (lhs: BookieApp.Book, rhs: BookieApp.Book) -> Bool {
        lhs.id == rhs.id
    }
}

private final class TestScreen: AnyBooksScreen {
    var viewModel: BooksViewModel<TestScreen>!

    @MainActor
    var testCheck: (@Sendable (DataSetType) -> Void)!

    required init(searchText: String, previousBook: Book?) {
        viewModel = BooksViewModel(screen: self, searchText: searchText, previousBook: previousBook)
    }

    func onNewDataReceived(oldSet _: DataSetType, newSet: DataSetType) async {
        await testCheck(newSet)
    }

    func onNewDataError(_: BooksViewModelError) async {}

    func onSearchTextChanged(_: String) async {}
}

class BookieTests: XCTestCase {
    private var screen: TestScreen!
    private static let expected = [Book(
        kind: "",
        id: "1",
        etag: "",
        volumeInfo: .init(
            title: "",
            authors: nil,
            publisher: nil,
            publishedDate: nil,
            description: nil,
            industryIdentifiers: nil,
            pageCount: nil,
            printType: nil,
            categories: nil,
            averageRating: nil,
            ratingsCount: nil,
            imageLinks: nil,
            language: "cs"
        ),
        saleInfo: nil,
        accessInfo: nil,
        searchInfo: nil
    )]

    override class func setUp() {
        super.setUp()

        let objectScope: ObjectScope = .container
        dependenciesContainer.register(RemoteDataSource.self) { _ in
            TestRemoteDataSource(expected: Self.expected)
        }.inObjectScope(objectScope)
    }

    func testAsyncMap() async {
        // Given
        let source = 10 as Int?

        // When
        let mappedValue = await source.mapAsync(Self.someAsyncFunc)

        // Then
        XCTAssertEqual(mappedValue, 100)
    }

    private static func someAsyncFunc(previousValue: Int) async -> Int {
        _ = try? await Task.sleep(nanoseconds: 1_000_000_000)
        return previousValue * previousValue
    }

    @MainActor
    func testBooksViewModel() async {
        screen = TestScreen(searchText: "", previousBook: nil)
        screen.testCheck = { @Sendable newSet in
            // Then
            XCTAssertEqual(newSet.first?.elements, Self.expected)
        }

        // When
        await screen.viewModel.reloadData()
    }
}

private struct TestRemoteDataSource: RemoteDataSource {
    let expected: [Book]

    func search(text _: String) async throws(BooksViewModelError) -> BookResponse {
        .init(
            kind: "",
            totalItems: expected.count,
            items: expected
        )
    }
}
