//
//  Models.swift
//  Bookie
//
//  Created by Roman Podymov on 27/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Foundation

// Root structure of the response
struct BookResponse: Codable {
    let kind: String
    let totalItems: Int
    let items: [Book]
}

// Representation of a single book
struct Book: Codable {
    let kind: String
    let id: String
    let etag: String
    let volumeInfo: VolumeInfo
    let saleInfo: SaleInfo?
    let accessInfo: AccessInfo?
    let searchInfo: SearchInfo?
}

// Volume information related to the book
struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let industryIdentifiers: [IndustryIdentifier]?
    let pageCount: Int?
    let printType: String?
    let categories: [String]?
    let averageRating: Double?
    let ratingsCount: Int?
    let imageLinks: ImageLinks?
    let language: String?
}

// Identifier for the book, like ISBN
struct IndustryIdentifier: Codable {
    let type: String
    let identifier: String
}

// Image links for the book (cover image)
struct ImageLinks: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
    let small: String?
    let medium: String?
    let large: String?
    let extraLarge: String?
}

// Sale information, including availability and price (if available)
struct SaleInfo: Codable {
    let country: String?
    let saleability: String?
    let isEbook: Bool?
    let price: Price?
}

// Pricing information for the book
struct Price: Codable {
    let amount: Double
    let currencyCode: String
}

// Access information for the book (such as permissions to view the book)
struct AccessInfo: Codable {
    let country: String
    let viewability: String
    let embeddable: Bool
    let publicDomain: Bool
    let textToSpeechPermission: String
    let epub: Epub?
    let pdf: PDF?
    let webReaderLink: String
}

// Epub-specific access information
struct Epub: Codable {
    let isAvailable: Bool
    let acsTokenLink: String?
}

// PDF-specific access information
struct PDF: Codable {
    let isAvailable: Bool
    let acsTokenLink: String?
}

// Search information, such as a snippet from the book
struct SearchInfo: Codable {
    let textSnippet: String?
}
