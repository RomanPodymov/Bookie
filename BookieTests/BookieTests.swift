//
//  BookieTests.swift
//  Bookie
//
//  Created by Roman Podymov on 24/02/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

@testable import BookieApp
import Testing

@Suite
struct BookieTests {
    @Test
    func testAsyncMap() async {
        let mappedValue = await (10 as Int?).mapAsync(someAsyncFunc)
        #expect(mappedValue == 101)
    }

    @Sendable private func someAsyncFunc(previousValue: Int) async -> Int {
        _ = try? await Task.sleep(nanoseconds: 1_000_000_000)
        return previousValue * previousValue
    }
}
