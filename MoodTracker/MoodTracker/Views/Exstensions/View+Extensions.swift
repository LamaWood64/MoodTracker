//
//  View+Extensions.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.

import SwiftUI

extension View {
    func iPadAdaptive() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
