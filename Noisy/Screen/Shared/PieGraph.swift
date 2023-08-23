//
//  PieGraph.swift
//  Noisy
//
//  Created by Davor Lakus on 23.08.2023..
//

import SwiftUI

enum BoundType {
    case lower
    case target
    case upper
}

struct PieGraph: View {
    @Binding var seedToggles: [Bool]
    @Binding var lowerBounds: [Double]
    @Binding var targets: [Double]
    @Binding var upperBounds: [Double]
    var width: CGFloat
    @Binding var isScrollDisabled: Bool
    @GestureState var isGestureActive: Bool = false
    let colors: [Color]

    var body: some View {
        ZStack {
            pieSlices(values: $upperBounds, opacity: 0.5, boundType: .upper)
            pieSlices(values: $targets, opacity: 0.7, boundType: .target)
            pieSlices(values: $lowerBounds, opacity: 0.9, boundType: .lower)
            seedNames()
            seedValues()
        }
        .frame(width: width, height: width)
    }
    
    func pieSlices(values: Binding<[Double]>, opacity: Double, boundType: BoundType) -> some View {
        ForEach(0..<values.count) { index in
            PieSlice(radius: width / 2.5,
                     radiusMultiplier: values[index].wrappedValue,
                     startAngle: Angle(degrees: 360 * Double(index) / Double(values.count)),
                     angle: Angle(degrees: 360 * 1.0 / Double(values.count)))
            .fill((seedToggles[index] ? colors[index] : .gray500).opacity(opacity))
            .highPriorityGesture(dragGesture(boundType: boundType, index: index))
            .simultaneousGesture(
                DragGesture()
                    .updating($isGestureActive) { _, state, _ in
                        state = true
                        withAnimation {
                            seedToggles[index] = true
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture()
                    .onChanged { _ in
                        withAnimation {
                            seedToggles[index] = true
                        }
                        isScrollDisabled = true
                    }
                    .onEnded { _ in
                        isScrollDisabled = false
                    }
            )
            .onChange(of: isGestureActive) { newValue in
                isScrollDisabled = newValue
            }
        }
    }
    
    func seedNames() -> some View {
        ForEach(0..<14) { index in
            Text(Seed.allCases[index].name)
                .font(.nunitoBold(size: 11))
                .padding(2)
                .padding(.horizontal, 2)
                .background { Color.appBackground }
                .mask(Capsule())
                .rotationEffect(textRotationAngle(for: index, total: 14))
                .offset(x: width / 3.5 * cos(for: index, total: 14),
                        y: width / 3.5 * sin(for: index, total: 14))
                .opacity(upperBounds[index] * upperBounds[index] * upperBounds[index])
                
        }
    }
    
    func seedValues() -> some View {
        ForEach(0..<14) { index in
            Text(Seed(rawValue: index)?.presentationalValue(targets[index]) ?? .noData)
                .font(.nunitoBold(size: 12))
                .padding(3)
                .background { (seedToggles[index] ? colors[index] : .gray500).opacity(0.7) }
                .mask(Capsule())
                .offset(x: width / 2.1 * cos(for: index, total: 14) * upperBounds[index],
                        y: width / 2.1 * sin(for: index, total: 14) * upperBounds[index])
                
        }
    }
    
    func cos(for index: Int, total: Int) -> CGFloat {
        Darwin.cos(angle(for: index, total: total).radians)
    }
    
    func sin(for index: Int, total: Int) -> CGFloat {
        Darwin.sin(angle(for: index, total: total).radians)
    }
    
    func angle(for index: Int, total: Int) -> Angle {
        Angle(degrees: 360 * (0.5 / 14 + Double(index) / 14))
    }
    
    func textRotationAngle(for index: Int, total: Int) -> Angle {
        if [10, 11, 12, 13, 0, 1, 2].contains(index) {
            return angle(for: index, total: total)
        }
        return angle(for: index, total: total) - .degrees(180)
    }
    
    func dragGesture(boundType: BoundType, index: Int) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let center = CGPoint(x: width/2, y: width/2)
                let radius = width / 2
                let distance = CGPointDistance(from: center, to: value.location) / radius + 0.15
                
                switch boundType {
                case .lower:
                    lowerBounds[index] = max(targets[index] - 0.1, distance)

                case .target:
                    targets[index] = max(lowerBounds[index] + 0.1, min(upperBounds[index] - 0.1, distance))
                case .upper:
                    upperBounds[index] = max(targets[index] + 0.1, min(1.0, distance))
                }
            }
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
}

struct PieSlice: Shape {
    @State var radius: CGFloat
    let radiusMultiplier: CGFloat
    let startAngle: Angle
    let angle: Angle
    var endAngle: Angle { startAngle + angle }
    var midAngle: Angle { startAngle + angle / 2 }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let start = CGPoint(x: rect.midX + cos(midAngle.radians) * 10, y: rect.midY + sin(midAngle.radians) * 10)
        path.move(to: start)
        path.addArc(center: start, radius: radius * radiusMultiplier, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        return path
    }
}
