//
//  VisualEffectBlur.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.
//

import SwiftUI

struct VisualEffectBlur: View {
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .allowsHitTesting(false)
    }
}
