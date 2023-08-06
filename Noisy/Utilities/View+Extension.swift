//
//  View+Extension.swift
//  Noisy
//
//  Created by Davor Lakus on 31.05.2023..
//

import SwiftUI

extension View {
    func tab(name: String, icon: Image) -> some View {
        Label { Text(name) } icon: { icon }
    }
    
    func loadingIndicator(isPresented: Binding<Bool>) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                SpinnerView()
            }
        }
    }
    
    @ViewBuilder
    func refreshGesture(offset: GestureState<CGFloat>, action: @escaping () -> Void) -> some View {
        ZStack {
            self
                .offset(y: offset.wrappedValue)
                .gesture(
                    DragGesture()
                        .updating(offset) { value, state, _ in
                            withAnimation {
                                state = min(value.translation.height, 100)
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 50 {
                                withAnimation {
                                    action()
                                }
                            }
                        }
                )
                .animation(.easeInOut, value: offset.wrappedValue > 0)
            
            VStack {
                ProgressView()
                    .padding()
                    .scaleEffect(x: 0.5 + offset.wrappedValue / 100, y: 0.5 + offset.wrappedValue / 100)
                    .opacity(offset.wrappedValue / 100)
                Spacer()
            }
        }
    }
    
    func alert<Alert: View>(isPresented: Binding<Bool>, alert: @escaping  () -> Alert) -> some View {
        ZStack {
            self
            alert()
        }
        .animation(.easeInOut, value: isPresented.wrappedValue)
    }
    
    func tabBarHidden(_ visibility: Binding<Visibility?>) -> some View {
        self
            .modifier(TabBarHidden(visibility: visibility))
    }
    
    func zStackTransition(_ transition: AnyTransition) -> some View {
        self
            .modifier(ZStackTransition(transition: transition))
    }
    
    @ViewBuilder
    func mintBadge(isPresented: Bool) -> some View {
        ZStack {
            if isPresented {
                ZStack(alignment: .topTrailing) {
                    self
                    Group {
                        Rectangle()
                            .fill(Color.appBackground)
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(Color.green200)
                            .frame(width: 8, height: 8)
                    }
                    .offset(x: 1.5, y: -1.5)
                }
                .transition(.opacity)
            } else {
                self
                    .transition(.opacity)
            }
        }
    }
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    @ViewBuilder
    func cardBackground(backgroundColor: Color = .cardBackground, borderColor: Color = .gray50, cornerRadius: CGFloat = Constants.cornerRadius, hasShadow: Bool = true, isHidden: Bool = false) -> some View {
        if isHidden {
            self
        } else {
            self
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
                .shadow(color: hasShadow ? .gray300 : .clear,
                        radius: 6, x: 1, y: 4)
        }
    }
    
    @ViewBuilder
    func cardBackground(gradient: LinearGradient, borderColor: Color = .gray50, cornerRadius: CGFloat = Constants.cornerRadius, hasBorder: Bool = false, hasShadow: Bool = true, isHidden: Bool = false) -> some View {
        if isHidden {
            self
        } else {
            self
                .background(gradient)
                .cornerRadius(cornerRadius)
                .overlay {
                    if hasBorder {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: 1)
                    }
                }
                .shadow(color: hasShadow ? .gray300 : .clear,
                        radius: 6, x: 1, y: 4)
        }
    }
    
    func bottomBorder() -> some View {
        overlay {
            VStack(spacing: .zero) {
                Spacer()
                Color.gray100
                    .frame(height: 1)
            }
        }
    }
    
    func navigationBarBottomBorder() -> some View {
        Color.gray300
            .padding(.top, 3.5)
            .frame(height: 4)
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
            .zIndex(5)
    }
    
    @ViewBuilder
    func modalSheet<Content: View>(isPresented: Binding<Bool>, content: () -> Content) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                content()
            }
        }
    }
    
    func highlightedText(_ text: String, query: String) -> some View {
        guard !text.isEmpty && !query.isEmpty else { return Text(text) }
        
        var result: Text?
        let components = text.lowercased().components(separatedBy: query.lowercased())
        let indicesOfQuery = text.lowercased().ranges(of: query.lowercased())
        
        components.indices.forEach { index in
            if let range = text.lowercased().range(of: components[index].lowercased()) {
                let currentSubstring = String(text[range])
                
                if let currentResult = result {
                    result = currentResult + Text(currentSubstring)
                } else {
                    result = Text(currentSubstring)
                }
            } else if result == nil {
                result = Text(String.empty)
            }
            
            if index != components.count - 1,
               let currentResult = result {
                result = currentResult + Text(text[indicesOfQuery[index]])
                    .foregroundColor(.mint)
                    .font(.nunitoSemiBold(size: 14))
            }
        }
        return result ?? Text(text)
    }
}

struct LoadImage: View {
    let url: URL?
    let placeholder: Image?
    
    init(url: URL?, placeholder: Image? = nil) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable()
        } placeholder: {
            if let placeholder {
                placeholder.resizable()
            } else {
                Image.Home.profile.resizable()
            }
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func swipeAction(title: String, gradient: [Color], height: CGFloat, offset: Binding<CGFloat>, action: @escaping () -> Void) -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Text(title)
                    .font(.nunitoBold(size: 14))
                    .foregroundColor(.appBackground)
                    .padding(10)
                    .frame(height: height)
            }
            .cardBackground(gradient: LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing), hasShadow: false)
            
            self
                .offset(x: offset.wrappedValue)
                .simultaneousGesture(dragGesture(offset: offset, action: action))
        }
    }
    
    func toast(isPresented: Binding<Bool>, message: String, alignment: Alignment = .bottom, duration: TimeInterval = 2.5) -> some View {
        ZStack(alignment: alignment) {
            self
            if isPresented.wrappedValue {
                Text(message)
                    .font(.nunitoBold(size: 18))
                    .foregroundColor(.white)
                    .padding(12)
                    .cardBackground(backgroundColor: .green200)
                    .zStackTransition(.slide)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
            }
        }
    }
    
    func circleOverlay(xOffset: CGFloat, yOffset: CGFloat, frameMultiplier: CGFloat = 2, color: Color = .yellow300) -> some View {
        CircleOverlay(xOffset: xOffset, yOffset: yOffset, frameMultiplier: frameMultiplier, color: color) {
            self
        }
    }
    
    func dragGesture(offset: Binding<CGFloat>, action: @escaping () -> Void) -> some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onChanged { dragValue in
                if dragValue.translation.width < 0 {
                    withAnimation {
                        offset.wrappedValue = dragValue.translation.width
                    }
                }
            }
            .onEnded { dragValue in
                if dragValue.translation.width < -100 {
                    withAnimation {
                        offset.wrappedValue = -300
                    }
                    action()
                } else {
                    withAnimation {
                        offset.wrappedValue = .zero
                    }
                }
            }
    }
}

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
