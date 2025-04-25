//
//  RealmDataSource.swift
//  Bookie
//
//  Created by Roman Podymov on 25/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Foundation
import Realm

struct RealmDataSource: RemoteDataSource {
    func search(text _: String) async throws (BooksViewModelError) -> BookResponse {
        fatalError()
    }
}
