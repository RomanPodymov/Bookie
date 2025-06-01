//
//  SwiftDataSource.swift
//  Bookie
//
//  Created by Roman Podymov on 27/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import SwiftData

@available(iOS 17, *)
@Model
final class BookSwiftData: Identifiable {
    @Attribute(.unique) var id: String
    var title: String

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

@available(iOS 17, *)
@ModelActor
actor SwiftDataSource: LocalDataSource {
    private var context: ModelContext { modelExecutor.modelContext }

    func search(text: String) async throws(BooksViewModelError) -> BookResponse {
        do {
            let books = try context.fetch(FetchDescriptor<BookSwiftData>()).map {
                Book(
                    kind: "",
                    id: $0.id,
                    etag: "",
                    volumeInfo: .init(
                        title: $0.title,
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
                )
            }
            let booksForTitle = books.filter { book in
                book.volumeInfo.title.contains(text)
            }
            return .init(kind: "", totalItems: booksForTitle.count, items: booksForTitle)
        } catch {
            throw BooksViewModelError.noData
        }
    }

    func save(books: [Book]) async throws(BooksViewModelError) {
        do {
            for book in books {
                context.insert(BookSwiftData(id: book.id, title: book.volumeInfo.title))
            }
            try context.save()
        } catch {
            throw BooksViewModelError.noData
        }
    }
}
