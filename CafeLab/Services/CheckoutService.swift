//
//  CheckoutService.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import Foundation

enum CheckoutResult {
    case success(orderID: String)
    case failure(String)
}

enum CheckoutService {
    static func placeOrder(items: [CartLine]) async -> CheckoutResult {
        try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5s simulated latency

        guard !items.isEmpty else {
            return .failure("Your cart is empty.")
        }

        // Occasionally simulate a failure so the error path is real, not theoretical.
        if Int.random(in: 0..<10) == 0 {
            return .failure(
                "The kitchen couldn't confirm your order. Please try again."
            )
        }

        let orderID = String(UUID().uuidString.prefix(8)).uppercased()
        return .success(orderID: orderID)
    }
}
