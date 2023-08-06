//
//  PlayerView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel: PlayerViewModel
    @State var albumWidth: CGFloat = 0
    @State var detents = Set<PresentationDetent>()
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
                .circleOverlay(xOffset: 0.3, yOffset: -0.4, frameMultiplier: 1.7, color: .mint600)
                .circleOverlay(xOffset: -0.8, yOffset: 0.8, color: .purple100)
                .circleOverlay(xOffset: 0.3, yOffset: 0.3, frameMultiplier: 1, color: .yellow100)
            
            bodyView()
                .toolbar(content: toolbarContent)
                .sheet(isPresented: $viewModel.isOptionsSheetPresented) {
                    OptionsView(isPresented: $viewModel.isOptionsSheetPresented, options: viewModel.options)
                        .readSize { detents = [.height($0.height)] }
                        .presentationDetents(detents)
                        .toast(isPresented: $viewModel.isToastPresented, message: viewModel.toastMessage)
                }
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    @State var width: CGFloat = .zero
    let isSliding: (Bool) -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray500)
                .frame(height: 4)
                .frame(maxWidth: .infinity)
                .readSize { width = $0.width }
            
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.green400)
                .frame(height: 5)
                .frame(width: width * value / range.upperBound + 10, height: 5)
            Circle()
                .fill(Color.orange100)
                .frame(width: 20, height: 20)
                .padding(.trailing, 5)
                .offset(x: width * value / range.upperBound)
                .gesture(
                    DragGesture()
                        .onChanged { dragValue in
                            isSliding(true)
                            if (0...width).contains(dragValue.location.x) {
                                withAnimation(.linear) {
                                    value = dragValue.location.x / width * range.upperBound
                                }
                            }
                        }
                        .onEnded { _ in
                            isSliding(false)
                        }
                )
        }
        .clipped()
    }
    
}

// MARK: - Body
extension PlayerView {
    func bodyView() -> some View {
        VStack(spacing: 28) {
            LoadImage(url: URL(string: viewModel.currentTrack?.album?.images.first?.url ?? .empty), placeholder: Image.albumPlaceholder)
                .readSize { albumWidth = $0.width }
                .frame(height: albumWidth)
                .cornerRadius(Constants.smallCornerRadius)
                .background {
                    Color.appBackground
                        .cornerRadius(Constants.smallCornerRadius)
                        .shadow(radius: 2)
                }
            trackTitleView()
            controlsView()
            footerView()
            Spacer()
        }
        .padding(Constants.margin)
    }
    
    func trackTitleView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(String.Track.name) \(viewModel.currentTrack?.name ?? .empty)")
                    .font(.nunitoBold(size: 18))
                    .foregroundColor(.gray600)
                Text("\(String.Track.artist) \(viewModel.currentTrack?.artists.first?.name ?? .empty)")
                    .font(.nunitoRegular(size: 16))
                    .foregroundColor(.gray500)
            }
            Spacer()
            Image.Player.plus
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.gray600)
                .background {
                    Color.appBackground
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(radius: 2)
                }
                .padding(.trailing, 20)
        }
    }
    
    func controlsView() -> some View {
        VStack(spacing: .zero) {
            progressBarView()
            playbackControlsView()
        }
    }
    
    func progressBarView() -> some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray300)
                    .frame(height: 2)
                ZStack(alignment: .trailing) {
                    CustomSlider(value: $viewModel.trackPosition,
                                 range: (0...viewModel.trackMaxPosition)) { isSliding in
                        if isSliding {
                            self.viewModel.sliderState = .slideStarted
                        } else {
                            self.viewModel.sliderState = .slideEnded(self.viewModel.trackPosition)
                        }
                    }
                }
            }
            
            HStack {
                Text(viewModel.trackPosition.positionalTime)
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.gray500)
                Spacer()
                Text(viewModel.trackMaxPosition.positionalTime)
                    .font(.nunitoRegular(size: 12))
                    .foregroundColor(.gray500)
            }
        }
    }
    
    func playbackControlsView() -> some View {
        HStack {
            Spacer()
            Button(action: viewModel.previousButtonTapped) {
                Image.Player.previous
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.gray600)
            }
            Spacer()
            Button(action: viewModel.playPauseButtonTapped) {
                (viewModel.isPlaying ? Image.Player.pauseCircle : Image.Player.playCircle)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .animation(.none, value: viewModel.isPlaying)
                    .foregroundColor(.green900)
            }
            Spacer()
            Button(action: viewModel.nextButtonTapped) {
                Image.Player.next
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.gray600)
            }
            Spacer()
        }
    }
    func footerView() -> some View {
        HStack(spacing: 48) {
            Image.Player.share
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            
            Button(action: viewModel.queueButtonTapped) {
                Image.Player.queue
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray600)
            }
        }
        .padding(.vertical, Constants.margin)
        .padding(.horizontal, 32)
        .background {
            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                .stroke(Color.green500, lineWidth: 3)
        }
        .background {
            Color.appBackground
                .cornerRadius(Constants.cornerRadius)
                .shadow(radius: 2)
        }
        
    }
}

// MARK: - Toolbar
extension PlayerView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle(.Player.queue)
        trailingToolbarButton()
    }
    
    @ToolbarContentBuilder
    func leadingToolbarButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: viewModel.backButtonTapped) {
                Image.Shared.chevronDown
                    .foregroundColor(.gray600)
            }
        }
    }
    
    @ToolbarContentBuilder
    func trailingToolbarButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: viewModel.optionsButtonTapped) {
                Image.Shared.threeDots
                    .foregroundColor(.gray600)
            }
        }
    }
}
