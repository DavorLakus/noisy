//
//  MiniPlayerView.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import SwiftUI
import Combine
import AVKit

final class MiniPlayerViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var isPlaying = false
    @Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    
    // MARK: - Coordinator actions
    let onDidTapMiniPlayer = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    let queueManager: QueueManager
    
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
        
        bindQueueManager()
    }
    
    func bindQueueManager() {
        queueManager.isPlaying.assign(to: &_isPlaying.projectedValue)
    }
    
    func playPauseButtonTapped() {
        queueManager.onPlayPauseTapped()
    }
    
    func miniPlayerTapped() {
        onDidTapMiniPlayer.send()
    }
}

struct MiniPlayerView: View {
    @ObservedObject var viewModel: MiniPlayerViewModel
    
    var body: some View {
        bodyView()
    }
}

// MARK: - Body view
extension MiniPlayerView {
    func bodyView() -> some View {
        HStack(spacing: 24) {
            (viewModel.isPlaying ? Image.Player.pause : Image.Player.play)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .foregroundColor(.red600)
                .highPriorityGesture(playPauseGesture())
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.queueManager.state.currentTrack.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(viewModel.queueManager.state.currentTrack.artists.first?.name ?? .empty)
                    .font(.nunitoSemiBold(size: 14))
                    .foregroundColor(.gray700)
                
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background { Color.appBackground.shadow(radius: 2) }
        .offset(y: -1)
        .onTapGesture(perform: viewModel.miniPlayerTapped)
    }
    
    func playPauseGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                viewModel.playPauseButtonTapped()
            }
    }
}
