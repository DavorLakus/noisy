//
//  CircleOverlay.swift
//  Noisy
//
//  Created by Davor Lakus on 07.08.2023..
//

import SwiftUI

struct CircleOverlay<Content: View>: View {
    @State var width: CGFloat = .zero
    let xOffset: CGFloat
    let yOffset: CGFloat
    let frameMultiplier: CGFloat
    let color: Color
    var content: () -> Content
    
    internal init(xOffset: CGFloat, yOffset: CGFloat, frameMultiplier: CGFloat, color: Color, content: @escaping () -> Content) {
        self.width = .zero
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.frameMultiplier = frameMultiplier
        self.color = color
        self.content = content
    }
    
    var body: some View {
        content()
            .readSize { size in
                withAnimation {
                    width = size.width
                }
            }
            .onAppear {
                withAnimation {
                    width /= frameMultiplier
                    width *= frameMultiplier
                }
            }
            .overlay {
                Circle()
                    .fill(color)
                    .frame(width: width * frameMultiplier, height: width * frameMultiplier)
                    .offset(x: width * xOffset, y: width * yOffset)
            }
    }
}

struct RandomCircleOverlay<Content: View>: View {
    @State var width: CGFloat = .zero
    @State var xOffsets: [CGFloat]
    @State var yOffsets: [CGFloat]
    @State var frameMultipliers: [CGFloat]
    let colors: [Color]
    var content: () -> Content
    
    internal init(colors: [Color], maxFrameMultiplier: CGFloat = 1.75, content: @escaping () -> Content) {
        self.width = .zero
        xOffsets = [CGFloat](repeating: 0.0, count: colors.count).map { $0 + CGFloat.random(in: -0.5...0.5) }

        yOffsets = [CGFloat](repeating: 0.0, count: colors.count).map { $0 + CGFloat.random(in: -0.5...0.5) }
        frameMultipliers = [CGFloat](repeating: 0.0, count: colors.count).map { $0 + CGFloat.random(in: 0.75...maxFrameMultiplier) }
        self.colors = colors
        self.content = content
    }
    
    func randomValuesArray(in range: ClosedRange<CGFloat>, count: Int) -> [CGFloat] {
        [CGFloat](repeating: 0.0, count: count).map { $0 + CGFloat.random(in: range) }
    }
    
    var body: some View {
        content()
            .readSize { size in
                withAnimation {
                    width = size.width
                }
            }
            .overlay {
                ForEach(Array(colors.enumerated()), id: \.offset) { color in
                    Circle()
                        .fill(color.element)
                        .frame(width: width * frameMultipliers[color.offset], height: width * frameMultipliers[color.offset])
                        .offset(x: width * xOffsets[color.offset], y: width * yOffsets[color.offset])
                }
            }
    }
}

extension View {
    func circleOverlay(xOffset: CGFloat, yOffset: CGFloat, frameMultiplier: CGFloat = 2, color: Color = .yellow300) -> some View {
        CircleOverlay(xOffset: xOffset, yOffset: yOffset, frameMultiplier: frameMultiplier, color: color) {
            self
        }
    }
    
    func randomCirclesOverlay(with colors: [Color]) -> some View {
        RandomCircleOverlay(colors: colors) {
            self
        }
    }
    
    func randomCirclesOverlay(count: Int, maxFrameMultiplier: CGFloat = 1.75) -> some View {
        RandomCircleOverlay(colors: Pastel.randomPastelColors(count: count), maxFrameMultiplier: maxFrameMultiplier) {
            self
        }
    }
}
