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
                ProgressView()
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
    
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func cardBackground(borderColor: Color = .gray50) -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(Constants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: Color.gray300,
                    radius: 6, x: 1, y: 4)
    }
    
    func navigationBarBottomBorder() -> some View {
        Color.gray300
            .padding(.top, 3.5)
            .frame(height: 4)
            .frame(maxWidth: .infinity)
            .background(Color.appBackground)
            .zIndex(5)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
