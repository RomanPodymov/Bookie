//
//  Extensions.swift
//  Bookie
//
//  Created by Roman Podymov on 06/03/2025.
//  Copyright © 2025 Bookie. All rights reserved.
//

import UIKit

extension Optional {
    func mapAsync<E, U>(_ transform: @Sendable (Wrapped) async throws (E) -> U) async throws (E) -> U? where E: Error, U: ~Copyable {
        if let self {
            return try await transform(self)
        } else {
            return nil
        }
    }
}

extension UIView {
    @discardableResult
    class func transition(
        with view: UIView,
        duration: TimeInterval,
        options: UIView.AnimationOptions = [],
        animations: (() -> Void)?
    ) async -> Bool {
        await withCheckedContinuation { continuation in
            Self.transition(
                with: view,
                duration: duration,
                options: options,
                animations: animations
            ) {
                continuation.resume(returning: $0)
            }
        }
    }
}
