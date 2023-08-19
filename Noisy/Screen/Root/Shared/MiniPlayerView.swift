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
    @Published var currentTrack: Track?
    @Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    
    // MARK: - Coordinator actions
    let onDidTapMiniPlayer = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    let queueManager: QueueManager
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Class lifecycle
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
        
        bindQueueManager()
    }
    
    func playPauseButtonTapped() {
        queueManager.onPlayPauseTapped()
    }
    
    func miniPlayerTapped() {
        onDidTapMiniPlayer.send()
    }
    
    func currentTrackArists() -> String {
        currentTrack?.artists.compactMap({ $0.name }).joined(separator: ", ") ?? .empty
    }
    
    func bindQueueManager() {
        queueManager.currentTrack
            .sink { [weak self] track in
                self?.currentTrack = track
            }
            .store(in: &cancellables)
        queueManager.isPlaying.assign(to: &_isPlaying.projectedValue)
    }
}

struct MiniPlayerView: View {
    @ObservedObject var viewModel: MiniPlayerViewModel
    
    var body: some View {
        bodyView()
            .ignoresSafeArea()
    }
}

// MARK: - Body view
extension MiniPlayerView {
    func bodyView() -> some View {
        HStack(spacing: 24) {
            (viewModel.isPlaying ? Image.Player.pause : Image.Player.playFill)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .foregroundColor(.purple900)
                .highPriorityGesture(playPauseGesture())
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.queueManager.state.currentTrack?.name ?? .empty)
                    .lineLimit(1)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(viewModel.currentTrackArists())
                    .lineLimit(1)
                    .font(.nunitoSemiBold(size: 14))
                    .foregroundColor(.gray600)
            }
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background {
            Color.appBackground
                .opacity(0.92)
                .shadow(radius: 4)
        }
        .onTapGesture(perform: viewModel.miniPlayerTapped)
    }
    
    func playPauseGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                viewModel.playPauseButtonTapped()
            }
    }
}
