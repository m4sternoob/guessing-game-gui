// FlipCardView.swift
// Reusable 3D flip card component

import SwiftUI

struct FlipCardView<FrontView: View, BackView: View>: View {
    @Binding var isFlipping: Bool
    @Binding var flipProgress: Double
    @Binding var flipDirection: ContentView.FlipDirection
    let frontView: FrontView
    let backView: BackView
    
    var body: some View {
        ZStack {
            // Front side (Guessing Game)
            frontView
                .opacity(isFlipping && flipDirection == .toBack ? max(0, 1 - flipProgress * 2) : (isFlipping && flipDirection == .toFront ? max(0, flipProgress * 2 - 1) : 1))
                .rotation3DEffect(
                    .degrees(isFlipping ? (flipDirection == .toBack ? -90 * flipProgress : 90 * (1 - flipProgress)) : (flipDirection == .toBack ? -90 : 0)),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
            
            // Back side (Snake Game)
            backView
                .opacity(isFlipping && flipDirection == .toBack ? max(0, flipProgress * 2 - 1) : (isFlipping && flipDirection == .toFront ? max(0, 1 - flipProgress * 2) : (flipDirection == .toBack ? 1 : 0)))
                .rotation3DEffect(
                    .degrees(isFlipping ? (flipDirection == .toBack ? 90 - 90 * flipProgress : -90 + 90 * flipProgress) : (flipDirection == .toBack ? 0 : 90)),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: flipProgress)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isFlipping)
    }
}