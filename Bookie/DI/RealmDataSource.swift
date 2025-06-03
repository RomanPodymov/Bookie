//
//  RealmDataSource.swift
//  Bookie
//
//  Created by Roman Podymov on 25/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Foundation
import RealmSwift

final class BookImageRealm: Object {
    @Persisted var smallThumbnail: String?
    @Persisted var thumbnail: String?
    @Persisted var small: String?
    @Persisted var medium: String?
    @Persisted var large: String?
    @Persisted var extraLarge: String?
}

final class BookRealm: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var image: BookImageRealm?
}

struct RealmDataSource: LocalDataSource {
    init() {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    }

    func search(text: String) async throws(BooksViewModelError) -> BookResponse {
        do {
            return try await Task { @MainActor in
                let realm = try await Realm()
                let books = realm.objects(BookRealm.self).map {
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
                            imageLinks: .init(
                                smallThumbnail: $0.image?.smallThumbnail,
                                thumbnail: $0.image?.thumbnail,
                                small: $0.image?.small,
                                medium: $0.image?.medium,
                                large: $0.image?.large,
                                extraLarge: $0.image?.extraLarge
                            ),
                            language: "cs"
                        ),
                        saleInfo: nil,
                        accessInfo: nil,
                        searchInfo: nil
                    )
                }
                let booksForTitle = Array(books.filter { book in
                    book.volumeInfo.title.contains(text)
                })
                return BookResponse(kind: "", totalItems: booksForTitle.count, items: booksForTitle)
            }.value
        } catch {
            throw BooksViewModelError.noData
        }
    }

    func save(books: [Book]) async throws(BooksViewModelError) {
        do {
            try await Task { @MainActor in
                let realm = try await Realm()
                for book in books {
                    try realm.write {
                        let obj = BookRealm().then {
                            $0.id = book.id
                            $0.title = book.volumeInfo.title
                            $0.image = BookImageRealm().then {
                                $0.smallThumbnail = book.volumeInfo.imageLinks?.smallThumbnail
                                $0.thumbnail = book.volumeInfo.imageLinks?.thumbnail
                                $0.small = book.volumeInfo.imageLinks?.small
                                $0.medium = book.volumeInfo.imageLinks?.medium
                                $0.large = book.volumeInfo.imageLinks?.large
                                $0.extraLarge = book.volumeInfo.imageLinks?.extraLarge
                            }
                        }
                        realm.add(obj, update: .modified)
                    }
                }
            }.value
        } catch {
            throw BooksViewModelError.noData
        }
    }
}
