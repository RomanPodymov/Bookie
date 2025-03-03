//
//  BookViewModel.swift
//  Bookie
//
//  Created by Roman Podymov on 03/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import Combine
import CombineMoya
import DifferenceKit
import Foundation
import Moya

protocol AnyBookScreen: AnyObject {}

class BookViewModel {
    unowned var screen: AnyBookScreen!

    var data: Book?

    init(screen: AnyBookScreen!, data: Book? = nil) {
        self.screen = screen
        self.data = data
    }
}
