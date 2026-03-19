//
//  BudgetTrackApp.swift
//  BudgetTrack
//
//  Created by Baran on 19.03.2026.
//

import SwiftUI
import FirebaseCore

@main
struct BudgetTrackApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
