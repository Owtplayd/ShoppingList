//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Brian Echeozo on 2025-04-18.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct ShoppingListApp: App {
    // Initialize Firebase
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
