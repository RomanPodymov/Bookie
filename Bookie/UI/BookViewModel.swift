//
//  BookViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

protocol AnyBookScreen: AnyObject {}

class BookViewModel {
    unowned var screen: AnyBookScreen!

    var data: VolumeInfo?

    init(screen: AnyBookScreen!, data: VolumeInfo? = nil) {
        self.screen = screen
        self.data = data
    }
}
