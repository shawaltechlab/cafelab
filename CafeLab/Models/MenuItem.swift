//
//  MenuItem.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import Foundation

struct MenuItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let category: String
    let isAvailable: Bool
    let thumbnailURL: String?
}
