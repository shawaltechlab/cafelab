//
//  CartLine.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import Foundation

/// One line in the cart: a menu item plus how many the user has added.
struct CartLine: Identifiable {
    var item: MenuItem
    var quantity: Int

    var id: Int { item.id }
    var subtotal: Double { item.price * Double(quantity) }
}
