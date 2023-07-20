//
//  PlayerViewModel.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine
import AVKit

enum PlayerSliderState {
    case reset
    case scrubStarted
    case scrubEnded(Double)
}

final class PlayerViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var isPlaying = false
    @Published var trackPosition: TimeInterval = 0
    @Published var observedPosition: TimeInterval = .zero
    @Published var trackMaxPosition: TimeInterval = 30
    @Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    @Published var scrubState: PlayerSliderState = .reset

    // MARK: - Coordinator actions
    var onDidTapDismissButton: PassthroughSubject<Void, Never>?
    let onDidTapOptionsButton = PassthroughSubject<Void, Never>()
    let onDidTapQueueButton = PassthroughSubject<Void, Never>()
    let onDidTapShareButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    var queueManager: QueueManager
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init(queueManager: QueueManager) {
        self.queueManager = queueManager
        bindQueueManager()
    }
    
    func bindQueueManager() {
        queueManager.isPlaying.assign(to: &_isPlaying.projectedValue)
        queueManager.trackPosition.assign(to: &_trackPosition.projectedValue)
        queueManager.observedPosition.assign(to: &_observedPosition.projectedValue)
        queueManager.trackMaxPosition.assign(to: &_trackMaxPosition.projectedValue)
        queueManager.timeControlStatus.assign(to: &_timeControlStatus.projectedValue)
        $scrubState.sink { [weak self] state in
            self?.queueManager.scrubState.send(state)
        }
        .store(in: &cancellables)
        
    }
}

// MARK: - Public extension
extension PlayerViewModel {
    
    func backButtonTapped() {
        onDidTapDismissButton?.send()
    }
    
    func optionsButtonTapped() {
        onDidTapOptionsButton.send()
    }
    
    func addToFavoritesButtonTapped() {
        
    }
    
    func previousButtonTapped() {
//        switch player.timeControlStatus {
//        case .paused:
//            <#code#>
//        case .waitingToPlayAtSpecifiedRate:
//            <#code#>
//        case .playing:
//            <#code#>
//        @unknown default:
//            <#code#>
//        }
    }

    func playPauseButtonTapped() {
        queueManager.onPlayPauseTapped()
    }
    
    func nextButtonTapped() {

    }
    
    func queueButtonTapped() {
        onDidTapQueueButton.send()
    }
    
    func shareButtonTapped() {
        onDidTapShareButton.send()
    }
}

final class QueueManager: ObservableObject {
    var state: QueueState
    var player = AVPlayer()
    let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(1000))
    
    var scrubState = CurrentValueSubject<PlayerSliderState, Never>(.reset)
    
    let trackPosition = CurrentValueSubject<TimeInterval, Never>(0)
    let observedPosition = CurrentValueSubject<TimeInterval, Never>(.zero)
    let trackMaxPosition = CurrentValueSubject<TimeInterval, Never>(30)
    let isPlaying = CurrentValueSubject<Bool, Never>(false)
    let timeControlStatus = CurrentValueSubject<AVPlayer.TimeControlStatus, Never>(.paused)
    
    private var itemDurationKVOPublisher: AnyCancellable?
    private var timeControlStatusKVOPublisher: AnyCancellable?
    var periodicTimeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    init(state: QueueState) {
        self.state = state
        
        trackPosition.send(state.currentTime)
        play(track: state.currentTrack)
        bindPlayer()
        bindScrubState()
    }
    
    func bindScrubState() {
        scrubState.sink { [weak self] state in
            switch state {
            case .reset: break
            case .scrubStarted: break
            case .scrubEnded(let seekTime):
                self?.player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1000))
            }
        }
        .store(in: &cancellables)
    }
    
    func seek(to seekTime: CMTime) {
        player.seek(to: seekTime)
    }
    
    func onPlayPauseTapped() {
        isPlaying.value ? pause() : play()
    }
    
    func play(track: Track? = nil) {
        if let track,
           let urlString = track.previewUrl,
           let url = URL(string: urlString) {
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        player.seek(to: CMTime(seconds: state.currentTime, preferredTimescale: 1000))
        player.play()
        isPlaying.send(true)
    }
    
    func pause() {
        player.pause()
        isPlaying.send(false)
    }
    
    func bindPlayer() {
        bindPeriodicTimeObserver()
        bindTimeControlStatus()
        bindItemDuration()
    }

    func bindTimeControlStatus() {
        timeControlStatusKVOPublisher = player
            .publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (newStatus) in
                guard let self = self else { return }
                self.timeControlStatus.send(newStatus)
            }
    }
    
    func bindItemDuration() {
        itemDurationKVOPublisher = player
            .publisher(for: \.currentItem?.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (newStatus) in
                guard let newStatus = newStatus,
                      let self = self else { return }
                if newStatus.seconds > 0 {
                    self.trackMaxPosition.send(newStatus.seconds)
                }
            }
    }
    
    func bindPeriodicTimeObserver() {
        self.periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            
            // Always update observed time.
            self.observedPosition.send(time.seconds)
            state.currentTime = time.seconds
            
            switch self.scrubState.value {
            case .reset:
                self.trackPosition.send(time.seconds)
            case .scrubStarted:
                // When scrubbing, the displayTime is bound to the Slider view, so
                // do not update it here.
                break
            case .scrubEnded(let seekTime):
                self.scrubState.send(.reset)
                self.trackPosition.send(seekTime)
            }
        }
    }
}

final class QueueState: Codable {
    var tracks: [Track]
    var currentTrack: Track
    var currentTrackIndex: Int
    var currentTime: TimeInterval
    
    init(tracks: [Track], currentTrackIndex: Int = 0) {
        self.tracks = tracks
        self.currentTrack = tracks[currentTrackIndex]
        self.currentTrackIndex = currentTrackIndex
        currentTime = .zero
    }
    
    func next() -> Track {
        if currentTrackIndex < tracks.count - 1 {
            currentTrackIndex += 1
            return tracks[currentTrackIndex]
        }
        currentTrackIndex = 0
        return tracks[currentTrackIndex]
    }
    
    func previous() -> Track {
        if currentTrackIndex > 0 {
            currentTrackIndex -= 1
            return tracks[currentTrackIndex]
        }
        currentTrackIndex -= 1
        return tracks[currentTrackIndex]
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension Formatter {
    static let positional: DateComponentsFormatter = {
        let positional = DateComponentsFormatter()
        positional.unitsStyle = .positional
        positional.zeroFormattingBehavior = .pad
        return positional
    }()
}

extension TimeInterval {
    var positionalTime: String {
        Formatter.positional.allowedUnits = self >= 3600 ?
        [.hour, .minute, .second] :
        [.minute, .second]
        let string = Formatter.positional.string(from: self)!
        return string.hasPrefix("0") && string.count > 4 ?
            .init(string.dropFirst()) : string
    }
}
