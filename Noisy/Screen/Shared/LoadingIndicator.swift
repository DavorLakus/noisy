//
//  LoadingIndicator.swift
//  Noisy
//
//  Created by Davor Lakus on 22.06.2023..
//

import SwiftUI

struct SpinnerView: View {
    let rotationTime: Double = 1.5
    let fullRotation: Angle = .degrees(360)
    let size: CGFloat = 52
    
    @State var start: CGFloat = 0.0
    @State var end: CGFloat = 0.05

    @State var angleS1: Angle = .degrees(240)
    @State var angleS2: Angle = .degrees(120)
    @State var angleS3: Angle = .degrees(0)
    
    var body: some View {
        
        ZStack {
            ZStack {
                SpinnerCircle(start: start, end: end, rotation: angleS1, color: .green300)
                    .frame(width: size * 0.4, height: size * 0.4)

                SpinnerCircle(start: start, end: end, rotation: angleS2, color: .purple100)
                    .frame(width: size * 0.7, height: size * 0.7)

                SpinnerCircle(start: start, end: end, rotation: angleS3, color: .orange400)
                    .frame(width: size, height: size)

            }
            .padding()
            .zStackTransition(.opacity)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: rotationTime, repeats: true) { _ in
                    self.animateSpinner()
                }
            }
        }
    }
    
    // MARK: Animation methods
    func animateSpinner() {
        animateSpinner(with: rotationTime / Double.random(in: 1...8)) {
            self.end = Double.random(in: 0...1)
        }
        
        animateSpinner(with: rotationTime / 5) {
            self.angleS1 += fullRotation
        }
        
        animateSpinner(with: rotationTime / 6) {
            self.angleS2 += fullRotation
        }
        
        animateSpinner(with: rotationTime / 7) {
            self.angleS3 += fullRotation
        }
                
        animateSpinner(with: rotationTime / Double.random(in: 1...8)) {
            self.end = Double.random(in: 0...1)
        }
    }
    
    func animateSpinner(with timeInterval: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            withAnimation(Animation.linear(duration: rotationTime)) {
                completion()
            }
        }
    }
    
}

struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color

    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .fill(color)
            .rotationEffect(rotation)
    }
}
