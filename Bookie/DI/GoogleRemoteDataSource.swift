//
//  GoogleRemoteDataSource.swift
//  Bookie
//
//  Created by Roman Podymov on 25/04/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import CombineMoya
import Foundation
import Moya

struct GoogleRemoteDataSource: RemoteDataSource {
    func search(text: String) async throws(BooksViewModelError) -> BookResponse {
        let provider = MoyaProvider<BooksService>(plugins: [
            NetworkLoggerPlugin(configuration: .init(
                logOptions: [.requestBody, .successResponseBody, .errorResponseBody]
            )),
        ])
        do {
            guard let response = try await provider.requestPublisher(.volumes(query: text)).values.first(
                where: { _ in true }
            ) else {
                throw BooksViewModelError.noData
            }
            do {
                return try JSONDecoder().decode(BookResponse.self, from: response.data)
            } catch {
                throw BooksViewModelError.parseError(error)
            }
        } catch {
            throw BooksViewModelError.requestError(error)
        }
    }
}
