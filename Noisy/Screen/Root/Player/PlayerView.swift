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
    
    var body: some View {
        bodyView()
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body
extension PlayerView {
    func bodyView() -> some View {
        VStack(spacing: 28) {
            Image.Shared.albumPlaceholder
                .resizable()
                .readSize { albumWidth = $0.width }
                .frame(height: albumWidth)
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
                Text("\(String.Track.name) \(viewModel.queueManager.state.currentTrack.name)")
                    .font(.nunitoBold(size: 18))
                    .foregroundColor(.gray600)
                Text("\(String.Track.artist) \(viewModel.queueManager.state.currentTrack.artists.first?.name ?? .empty)")
                    .font(.nunitoRegular(size: 16))
                    .foregroundColor(.gray500)
            }
            Spacer()
            Image.Player.plus
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.gray600)
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
                    Slider(value: $viewModel.trackPosition, in: (0...viewModel.trackMaxPosition)) { isSliding in
                        if isSliding {
                            self.viewModel.scrubState = .scrubStarted
                        } else {
                            self.viewModel.scrubState = .scrubEnded(self.viewModel.trackPosition)
                        }
                    }
                    .tint(Color.green400)
                }
            }
            
            HStack {
                Text(viewModel.observedPosition.positionalTime)
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
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.orange100, lineWidth: 4)
        }
        .background { Color.appBackground.cornerRadius(32) }
        .shadow(radius: 1)
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
                Image.Player.threeDots
                    .foregroundColor(.gray600)
            }
        }
    }
}
