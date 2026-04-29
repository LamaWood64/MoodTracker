//  MoodTrackerApp.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.
//

import SwiftUI

@main
struct MoodTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MoodSelectionView()
                .preferredColorScheme(.dark) 
        }
    }
}
