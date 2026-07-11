//
//  CardManager.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import Combine
import Foundation

enum CheckoutState: Equatable {
    case idle
    case loading
    case success(orderID: String)
    case failure(String)
}

@MainActor
final class CartManager: ObservableObject {
    @Published private(set) var lines: [Int: CartLine] = [:]
    @Published var checkoutState: CheckoutState = .idle

    var orderedLines: [CartLine] {
        lines.values.sorted { $0.item.name < $1.item.name }
    }

    var totalItemCount: Int {
        lines.values.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Double {
        lines.values.reduce(0) { $0 + $1.subtotal }
    }

    func quantity(for itemID: Int) -> Int {
        lines[itemID]?.quantity ?? 0
    }

    func add(_ item: MenuItem) {
        guard item.isAvailable else { return }
        if var existing = lines[item.id] {
            existing.quantity += 1
            lines[item.id] = existing
        } else {
            lines[item.id] = CartLine(item: item, quantity: 1)
        }
    }

    func increment(_ itemID: Int) {
        guard var line = lines[itemID] else { return }
        line.quantity += 1
        lines[itemID] = line
    }

    func decrement(_ itemID: Int) {
        guard var line = lines[itemID] else { return }
        line.quantity -= 1
        if line.quantity <= 0 {
            lines.removeValue(forKey: itemID)
        } else {
            lines[itemID] = line
        }
    }

    func remove(_ itemID: Int) {
        lines.removeValue(forKey: itemID)
    }

    func placeOrder() async {
        checkoutState = .loading
        let result = await CheckoutService.placeOrder(items: orderedLines)
        switch result {
        case .success(let orderID):
            checkoutState = .success(orderID: orderID)
            lines.removeAll()
        case .failure(let message):
            checkoutState = .failure(message)
        }
    }

    func resetCheckoutState() {
        checkoutState = .idle
    }
}
