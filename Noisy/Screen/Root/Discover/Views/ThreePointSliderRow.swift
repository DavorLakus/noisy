//
//  ThreePointSliderRow.swift
//  Noisy
//
//  Created by Davor Lakus on 30.07.2023..
//

import SwiftUI

struct ThreePointSliderRow: View {
    let seed: Seed
    let infoAction: (Seed) -> Void
    
    var numberFormat: String { seed.isInt ? "%d" : "%.2f" }
    
    let minValue: Double
    let maxValue: Double
    @Binding var lowerBound: Double
    @Binding var target: Double
    @Binding var upperBound: Double
    @Binding var isToggled: Bool
    
    var lowerBoundString: String { valueToString(lowerBound) }
    var targetString: String { valueToString(target) }
    var upperBoundString: String { valueToString(upperBound) }
    
    @State var isExpanded: Bool = false
    let markRadius: CGFloat = 20
    
    let lowerBoundColor: Color = .red300
    let targetColor: Color = .yellow200
    let upperBoundColor: Color = .orange400
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack {
                Text(seed.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 20))
                
                Button {
                    infoAction(seed)
                } label: {
                    Image.Shared.info.foregroundColor(.green500)
                }
                
                (isToggled ? Image.Shared.checkboxFill : Image.Shared.checkbox)
                    .onTapGesture {
                        withAnimation {
                            isToggled.toggle()
                        }
                    }
                    .foregroundColor(.green500)
                
                Spacer()
                
                Image.Shared.chevronDown
                    .rotationEffect(Angle(degrees: isExpanded ? 0 : -90))
            }
            .padding(.bottom, isExpanded ? 12 : .zero)
            .background(isToggled ? Color.green200 : Color.white)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                HStack {
                    HStack(spacing: .zero) {
                        Text(String.Discover.lowerBound)
                            .foregroundColor(.appBackground)
                            .font(.nunitoBold(size: 12))
                        Text(lowerBoundString)
                            .foregroundColor(lowerBoundColor)
                            .font(.nunitoBold(size: 14))
                    }
                    Spacer()
                    HStack(spacing: .zero) {
                        Text(String.Discover.target)
                            .foregroundColor(.appBackground)
                            .font(.nunitoBold(size: 12))
                        Text(targetString)
                            .foregroundColor(targetColor)
                            .font(.nunitoBold(size: 14))
                    }
                    Spacer()
                    HStack(spacing: .zero) {
                        Text(String.Discover.upperBound)
                            .foregroundColor(.appBackground)
                            .font(.nunitoBold(size: 12))
                        Text(upperBoundString)
                            .foregroundColor(upperBoundColor)
                            .font(.nunitoBold(size: 14))
                    }
                }
                .animation(.none, value: lowerBound)
                .animation(.none, value: target)
                .animation(.none, value: upperBound)
                .padding(markRadius)
                .cardBackground(backgroundColor: .green500, cornerRadius: markRadius * 2)
                .padding(.bottom, 40)
                
                ThreePointSlider(minValue: minValue, maxValue: maxValue, lowerBound: $lowerBound, target: $target, upperBound: $upperBound, minColor: lowerBoundColor, targetColor: targetColor, maxColor: upperBoundColor)
            }
        }
        .padding(Constants.margin)
        .cardBackground(backgroundColor: isToggled ? Color.green200 : Color.white)
    }
    
    func valueToString(_ value: Double) -> String {
        if case .duration = seed {
            return TimeInterval(value * seed.multiplier).positionalTime
        } else {
            return String(format: numberFormat, seed.isInt ? Int(value * seed.multiplier) : value)
        }
    }
}

// MARK: - Info alert
private extension ThreePointSliderRow {
  
}

struct ThreePointSlider: View {
    let minValue: Double
    let maxValue: Double
    @Binding var lowerBound: Double
    @Binding var target: Double
    @Binding var upperBound: Double
    
    let fontSize: CGFloat = 12
    var radius: CGFloat { width / 15 }
    var tolerance: CGFloat = 0.09
    let toleranceOffset: CGFloat = 0.01
    
    @State var width: CGFloat = 0
    @State var textWidth: CGFloat = 0
    @State var textHeight: CGFloat = 0
    
    let minColor: Color
    let targetColor: Color
    let maxColor: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            VStack(spacing: 4) {
                HStack(spacing: .zero) {
                    Text(String.Discover.min)
                        .offset(x: lowerBoundOffset() + textWidth / 3, y: -textHeight * 1.5)
                        .gesture(lowerBoundDragGesture())
                        .foregroundColor(.gray500)
                        .font(.nunitoBold(size: fontSize))
                        .readSize {
                            textWidth = $0.width
                            textHeight = $0.height
                        }
                    Text(String.Discover.targetShort)
                        .offset(x: targetOffset(), y: -textHeight * 0.75)
                        .gesture(targetDragGesture())
                        .foregroundColor(.gray500)
                        .font(.nunitoBold(size: fontSize))
                    Text(String.Discover.max)
                        .offset(x: upperBoundOffset() - textWidth / 3)
                        .gesture(upperBoundDragGesture())
                        .foregroundColor(.gray500)
                        .font(.nunitoBold(size: fontSize))
                    Spacer()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.appBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                        .readSize { width = $0.width }
                    
                    HStack(spacing: .zero) {
                        lowerBoundDot()
                            .offset(x: lowerBoundOffset())
                            .gesture(lowerBoundDragGesture())
                        targetDot()
                            .offset(x: targetOffset())
                            .gesture(targetDragGesture())
                        upperBoundDot()
                            .offset(x: upperBoundOffset())
                            .gesture(upperBoundDragGesture())
                        Spacer()
                    }
                }
                .padding(radius / 2)
                .background {
                    RoundedRectangle(cornerRadius: radius)
                        .fill(Color.altGray)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    func lowerBoundOffset() -> CGFloat {
        lowerBound * width
    }
    
    func targetOffset() -> CGFloat {
        target * width - radius  * 1.45
    }
    
    func upperBoundOffset() -> CGFloat {
        upperBound * width - radius * 2.9
    }
    
    func lowerBoundDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if lowerBound < target - tolerance {
                        lowerBound = (value.location.x - 0.5 * radius) / width
                    } else {
                        lowerBound = target - tolerance
                    }
                    if lowerBound < 0 {
                        lowerBound = 0
                    }
                }
            }
            .onEnded { _ in
                withAnimation {
                    if lowerBound > target - tolerance - toleranceOffset {
                        lowerBound = target - tolerance - toleranceOffset
                    }
                }
            }
    }
    
    func targetDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if lowerBound < target - tolerance && target + tolerance < upperBound {
                        target = (value.location.x + 1 * radius) / width
                    } else if lowerBound > target - tolerance {
                        target = lowerBound + tolerance
                    } else if upperBound < target + tolerance {
                        target = upperBound - tolerance
                    }
                }
            }
            .onEnded { _ in
                withAnimation {
                    if target < lowerBound + tolerance + toleranceOffset {
                        target = lowerBound + tolerance + toleranceOffset
                    }
                    if target > upperBound - tolerance - toleranceOffset {
                        target = upperBound - tolerance - toleranceOffset
                    }
                    
                }
            }
    }
    
    func upperBoundDragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    if upperBound > target + tolerance {
                        upperBound = (value.location.x + 2.5 * radius) / width
                    } else {
                        upperBound = target + tolerance
                    }
                    if upperBound > 1 {
                        upperBound = 1
                    }
                }
            }
            .onEnded { _ in
                withAnimation {
                    if upperBound < target + tolerance + toleranceOffset {
                        upperBound = target + tolerance + toleranceOffset
                    }
                }
            }
    }
    
    func lowerBoundDot() -> some View {
        Dot(fillColor: minColor, radius: radius)
    }
    
    func targetDot() -> some View {
        Dot(fillColor: targetColor, radius: radius)
    }
    
    func upperBoundDot() -> some View {
        Dot(fillColor: maxColor, radius: radius)
    }
}

struct Dot: View {
    let fillColor: Color
    //    let strokeColor: Color
    let radius: CGFloat
    let strokeWidth: CGFloat = 0
    
    init(fillColor: Color, radius: CGFloat = 20) {
        self.fillColor = fillColor
        //        self.strokeColor = strokeColor
        self.radius = radius
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: radius - strokeWidth, height: radius - strokeWidth)
            
            //            Circle()
            //                .stroke(strokeColor, lineWidth: strokeWidth)
            //                .frame(width: radius, height: radius)
        }
    }
}
