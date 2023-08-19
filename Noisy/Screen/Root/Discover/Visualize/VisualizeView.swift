//
//  VisualizeView.swift
//  Noisy
//
//  Created by Davor Lakus on 15.08.2023..
//

import SwiftUI

struct VisualizeView: View {
    @ObservedObject var viewModel: VisualizeViewModel
    
    @State private var scaleFactor: CGFloat = 1
    @State private var screenSize: CGSize = .zero
    @State var zoomReset = true
    
    var minScale = 0.7
    var maxScale = 1.3
    var positionMultiplier = 500.0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
                .randomCirclesOverlay(count: 3)
                .opacity(0.05)
            
            bodyView()
            headerView()
        }
        .ignoresSafeArea(edges: .all)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .tabBarHidden($viewModel.tabBarVisibility)

    }
}

// MARK: - Header
private extension VisualizeView {
    func headerView() -> some View {
        VStack(alignment: .leading) {
            Button(action: viewModel.backButtonTapped) {
                Image.Shared.chevronLeft
                    .foregroundColor(.appBackground)
                    .padding(8)
                    .background {
                        Circle()
                            .fill(Color.mint600)
                            .shadow(radius: 2)
                    }
            }
            HStack {
                Spacer()
                Text(String.Visualize.visualize)
                    .font(.nunitoBold(size: 24))
                    .foregroundColor(.gray800)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color.appBackground)
                            .shadow(radius: 2)
                    }
            }
        }
        .padding(.top, Constants.mediumIconSize)
        .padding(Constants.margin)
    }
    
    func bodyView() -> some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            if viewModel.recommendedTracks.count == viewModel.trackPositions.count {
                ZStack(alignment: .center) {
                    Text("CENTER")
                    ForEach(Array(viewModel.recommendedTracks.enumerated()), id: \.offset) { enumeratedTrack in
//                        Circle()
//                            .fill(Pastel.allCases.randomElement()?.color ?? .yellow300)
//                            .frame(width: 10, height: 10)
                        Text("\(enumeratedTrack.offset + 1)")
                            .position(viewModel.trackPositions[enumeratedTrack.offset] * (positionMultiplier / 2) + positionMultiplier / 2)
                    }
                    ForEach(Array(viewModel.audioFeaturePoints.enumerated()), id: \.offset) { enumeratedFeaturePoint in
//                        Circle()
//                            .fill(Pastel.allCases.randomElement()?.color ?? .yellow300)
//                            .frame(width: 10, height: 10)
                        Text("feature")
                            .position(enumeratedFeaturePoint.element * (positionMultiplier))
                    }
                }
                .background { Color.red50 }
                .frame(width: positionMultiplier, height: positionMultiplier)
                .padding(Constants.margin)
                .readSize { size in
                    screenSize = size
                }
                .frame(width: screenSize.width * scaleFactor, height: screenSize.height * scaleFactor)
                .scaleEffect(scaleFactor, anchor: .center)
                .padding()
                
            }
//            if let root = viewModel.currentTree.first {
//                GraphView(root: root, viewModel: viewModel)
//                    .readSize { size in
//                        screenSize = size
//                    }
//                    .frame(width: screenSize.width * scaleFactor, height: screenSize.height * scaleFactor)
//                    .scaleEffect(scaleFactor, anchor: .center)
//                    .padding()
//            }
        }
//        .readSize(onChange: { <#CGSize#> in
//            <#code#>
//        })
        .highPriorityGesture(magnificationGesture())
    }
}

// MARK: - Gesture
private extension VisualizeView {
    func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged({ magnification in
                if magnification <= maxScale && magnification >= minScale {
                    withAnimation {
                        scaleFactor = max(minScale, min(maxScale, zoomReset ? magnification : scaleFactor * magnification))
                    }
                } else if magnification > maxScale {
                    withAnimation {
                        scaleFactor = maxScale
                        zoomReset = true
                    }
                } else if magnification < minScale {
                    withAnimation {
                        scaleFactor = minScale
                    }
                }
            })
            .onEnded({ _ in
                zoomReset = false
                withAnimation {
                    if scaleFactor >= maxScale {
                        scaleFactor = maxScale
                        zoomReset = true
                    } else if scaleFactor <= minScale {
                        scaleFactor = minScale
                    }
                }
            })
    }
}

//
//import SwiftUI
//import Defines
//
//struct GraphView: View {
//    @ObservedObject var root: EmployeeCard
//    @ObservedObject var viewModel: OrganizationViewModel
//
//    var body: some View {
//        VStack(alignment: .center, spacing: 0) {
//            UserCard(employee: root, viewModel: viewModel)
//            if !root.teamMembers.isEmpty, root.isOpened {
//                Rectangle()
//                    .fill(Color.lineGray)
//                    .frame(width: 2.0, height: 50)
//                Rectangle()
//                    .fill(root.teamMembers.count == 1 ? Color.lineGray : Color.clear)
//                    .frame(width: 2.0, height: 50)
//
//                HStack(alignment: .top, spacing: Constants.margin) {
//                    ForEach(root.teamMembers) { employee in
//                        GraphView(root: employee, viewModel: viewModel)
//                            .anchorPreference(key: TopPreferenceKey.self, value: .top) { anchor in
//                                return [TopPreference(id: employee.id, top: anchor)]
//                            }
//                    }
//                }
//                .backgroundPreferenceValue(TopPreferenceKey.self) { (tops: [TopPreference]) in
//                    GeometryReader { geo in
//                        ForEach(tops.indices, id: \.self) { index in
//                            if index < tops.count - 1 {
//                                Line(start: geo[tops[index].top], end: geo[tops[index + 1].top]).stroke(lineWidth: 2.0).foregroundColor(.lineGray)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .drawingGroup()
//    }
//}


extension CGPoint {
    static func * (_ lhs: CGPoint, _ rhs: Double) -> CGPoint {
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func + (_ lhs: CGPoint, _ rhs: Double) -> CGPoint {
        return CGPoint(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    func round() -> CGPoint {
        return CGPoint(x: self.x.roundToPlaces(places: 2), y: self.y.roundToPlaces(places: 2))
    }
}

extension CGFloat {
    func roundToPlaces(places:Int) -> Double {
            let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        }
}

extension Double {
    func roundToPlaces(_ places: Int) -> Double {
        let divisor = pow(10.0, Double(2))
        return (self * divisor).rounded() / divisor
    }
}
