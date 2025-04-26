//
//  RealmDataSource.swift
//  Bookie
//
//  Created by Roman Podymov on 25/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Foundation
import RealmSwift

class BookRealm: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
}

struct RealmDataSource: LocalDataSource {
    init() {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    }

    func search(text _: String) async throws (BooksViewModelError) -> BookResponse {
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
                            imageLinks: nil,
                            language: "cs"
                        ),
                        saleInfo: nil,
                        accessInfo: nil,
                        searchInfo: nil
                    )
                }
                return BookResponse(kind: "", totalItems: books.count, items: Array(books))

            }.value
        } catch {
            throw BooksViewModelError.noData
        }
    }

    func save(books: [Book]) async throws (BooksViewModelError) {
        do {
            try await Task { @MainActor in
                let realm = try await Realm()
                try realm.write {
                    realm.deleteAll()
                }
                for book in books {
                    try realm.write {
                        let obj = BookRealm()
                        obj.id = book.id
                        obj.title = book.volumeInfo.title
                        realm.add(obj)
                    }
                }
            }.value
        } catch {
            throw BooksViewModelError.noData
        }
    }
}
