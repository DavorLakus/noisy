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
    @State private var barWidth: CGFloat = .zero
    @State var zoomReset = true
    
    var minScale = 0.7
    var maxScale = 2.0
    var positionMultiplier = 500.0
    
    private let iconSize: CGFloat = 60.0
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()
            
            bodyView()
            headerView()
        }
        .alert(isPresented: $viewModel.isTrackInfoPresented, alert: audioFeaturesView)
        .alert(isPresented: $viewModel.isSeedInfoAlertPresented) { isPresented in
            AlertView(isPresented: isPresented, title: viewModel.infoSeed?.name, message: viewModel.infoSeed?.description, secondaryActionText: .Shared.ok)
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
        HStack {
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
                    ForEach(Array(viewModel.recommendedTracks.enumerated()), id: \.offset) { enumeratedTrack in
                        trackIcon(for: enumeratedTrack)
                    }
                }
                .background {
                    RadialGradient(colors: [.red300, .appBackground], center: .center, startRadius: .zero, endRadius: screenSize.width / 2)
                        .randomCirclesOverlay(count: 3)
                        .opacity(0.05)
                }
                .frame(width: positionMultiplier, height: positionMultiplier)
                .padding(Constants.margin)
                .readSize { size in
                    screenSize = size
                }
                .frame(width: screenSize.width * scaleFactor, height: screenSize.height * scaleFactor)
                .scaleEffect(scaleFactor, anchor: .center)
                .padding(Constants.mediumIconSize)
            }
        }
        .highPriorityGesture(magnificationGesture())
    }
    
    func trackIcon(for track: EnumeratedSequence<[Track]>.Element) -> some View {
        ZStack {
            Circle().fill(Pastel.randomPastelColors(count: 1)[0])
                .frame(width: iconSize, height: iconSize)
            if let albumImage = track.element.album?.images.first {
                LoadImage(url: URL(string: albumImage.url))
                    .frame(width: iconSize - 5, height: iconSize - 5)
                    .mask(Circle())
            }
        }
        .onTapGesture {
            viewModel.trackIconTapped(track: track)
        }
        .position(viewModel.trackPositions[track.offset] * (positionMultiplier / 2) + positionMultiplier / 2)
    }
}

// MARK: - Track audio features view
private extension VisualizeView {
    func audioFeaturesView(isPresented: Binding<Bool>) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Constants.margin) {
                if let enumeratedTrack = viewModel.selectedTrack {
                    audioFeaturesHeaderView(enumeratedTrack)
                    
                    ForEach(Array(viewModel.tracksFeatures[enumeratedTrack.offset].associatedSeeds.enumerated()), id: \.offset) { enumeratedFeature in
                        featureRow(seed: enumeratedFeature.element, value: viewModel.tracksFeatures[enumeratedTrack.offset].normalizedValues[enumeratedFeature.offset], infoAction: viewModel.seedInfoTapped)
                    }
                }
            }
        }
        .padding(Constants.margin)
        .cardBackground(backgroundColor: .appBackground, hasShadow: false)
        .padding(Constants.margin)
        .padding(.vertical, Constants.mediumIconSize)
    }
    
    func featureRow(seed: Seed, value: Double, infoAction: @escaping (Seed) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Group {
                    Text("\(seed.name):")
                        
                    switch seed {
                    case .key:
                        Text(Seed.musicKeyFromValue(value * seed.multiplier))
                    case .mode:
                        Text(Seed.modeFromValue(value))
                    case .timeSignature:
                        Text("\(Int(value * seed.multiplier))/4")
                    case .tempo:
                        Text("\(Int(value * seed.multiplier))")
                    default:
                        Text(String(format:"%.2f", (value * seed.multiplier)))
                    }
                }
                .foregroundColor(.gray700)
                .font(.nunitoSemiBold(size: 16))
                
                Button {
                    infoAction(seed)
                } label: {
                    Image.Shared.info.foregroundColor(.green500)
                }
            }
            ZStack {
                Color.gray200
                HStack(spacing: .zero) {
                    Pastel.randomPastelColors(count: 1)[0]
                        .frame(width: barWidth * value / 1.0)
                        .padding(.trailing, Constants.cornerRadius)
                        .cornerRadius(Constants.cornerRadius)
                        .padding(.trailing, -Constants.cornerRadius)
                    Spacer()
                }
            }
            .readSize { barWidth = $0.width }
            .cornerRadius(Constants.cornerRadius)
        }
    }
    
    func audioFeaturesHeaderView(_ enumeratedTrack: EnumeratedSequence<[Track]>.Element) -> some View {
        VStack(alignment: .trailing) {
            Button {
                withAnimation {
                    viewModel.isTrackInfoPresented = false
                }
            } label: {
                Image.Shared.close
            }
            
            HStack(spacing: .zero) {
                if let urlString = enumeratedTrack.element.album?.images.first {
                    LoadImage(url: URL(string: urlString.url))
                        .frame(width: 80, height: 80)
                        .mask(Circle())
                }
                VStack(alignment: .trailing, spacing: 4) {
                    Text(enumeratedTrack.element.name)
                        .foregroundColor(.gray800)
                        .font(.nunitoBold(size: 24))
                        .frame(maxWidth: .infinity)

                    if let artist = enumeratedTrack.element.artists.first {
                        HStack {
                            Text("by")
                                .font(.nunitoBold(size: 14))
                                .foregroundColor(.gray600)
                            
                            Text(artist.name)
                                .foregroundColor(.gray800)
                                .font(.nunitoBold(size: 18))
                        }
                        .padding(.leading, Constants.margin)
                    }
                }
            }
        }
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
