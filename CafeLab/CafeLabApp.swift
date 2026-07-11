//
//  CafeLabApp.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import SwiftUI

@main
struct CafeLabApp: App {
    @StateObject private var cartManager = CartManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MenuView()
            }
            .environmentObject(cartManager)
        }
    }
}
