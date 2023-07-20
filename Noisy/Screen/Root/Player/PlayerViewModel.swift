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
    @Published var trackPosition: TimeInterval = 0
    @Published var observedPosition: TimeInterval = .zero
    @Published var trackMaxPosition: TimeInterval = 30
    @Published var isPlaying = false
    @Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused

    var player = AVPlayer()
    var scrubState: PlayerSliderState = .reset {
       didSet {
          switch scrubState {
          case .reset: break
          case .scrubStarted: break
          case .scrubEnded(let seekTime):
              player.seek(to: CMTime(seconds: seekTime, preferredTimescale: 1000))
          }
       }
    }
    let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(1000))
    
    // MARK: - Coordinator actions
    var onDidTapDismissButton: PassthroughSubject<Void, Never>?
    let onDidTapOptionsButton = PassthroughSubject<Void, Never>()
    let onDidTapQueueButton = PassthroughSubject<Void, Never>()
    let onDidTapShareButton = PassthroughSubject<Void, Never>()
    
    // MARK: - Public properties
    let queueManager: QueueState
    
    // MARK: - Private properties
    private let playerService: PlayerService
    
    private var itemDurationKVOPublisher: AnyCancellable?
    private var timeControlStatusKVOPublisher: AnyCancellable?
    var periodicTimeObserver: Any?

    // MARK: - Class lifecycle
    init(playerService: PlayerService, queueManager: QueueState) {
        self.playerService = playerService
        self.queueManager = queueManager
        bindPlayer()
    }
}

// MARK: - Public extension
extension PlayerViewModel {
    func viewDidAppear() {
        trackPosition = queueManager.currentTime
        play(track: queueManager.currentTrack)
    }
    
    func viewWillDisappear() {
        queueManager.currentTime = observedPosition
    }
    
    func backButtonTapped() {
        onDidTapDismissButton?.send()
    }
    
    func optionsButtonTapped() {
        onDidTapOptionsButton.send()
    }
    
    func addToFavoritesButtonTapped() {
        
    }
    
    func play(track: Track? = nil) {
        if let track,
           let urlString = track.previewUrl,
           let url = URL(string: urlString) {
            print(track.name)
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        player.seek(to: CMTime(seconds: queueManager.currentTime, preferredTimescale: 1000))
        player.play()
        isPlaying = true
    }
    
    func pause() {
        player.pause()
        isPlaying = false
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
        isPlaying ? pause() : play()
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

private extension PlayerViewModel {
    func bindPlayer() {
        bindPeriodicTimeObserver()
        bindTimeControlStatus()
        bindItemDuration()
    }
    
    func bindPeriodicTimeObserver() {
        self.periodicTimeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] (time) in
            guard let self = self else { return }
            
            // Always update observed time.
            self.observedPosition = time.seconds
            queueManager.currentTime = time.seconds
            
            switch self.scrubState {
            case .reset:
                self.trackPosition = time.seconds
            case .scrubStarted:
                // When scrubbing, the displayTime is bound to the Slider view, so
                // do not update it here.
                break
            case .scrubEnded(let seekTime):
                self.scrubState = .reset
                self.trackPosition = seekTime
            }
        }
    }
    
    func bindTimeControlStatus() {
        timeControlStatusKVOPublisher = player
            .publisher(for: \.timeControlStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (newStatus) in
                guard let self = self else { return }
                self.timeControlStatus = newStatus
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
                    self.trackMaxPosition = newStatus.seconds
                }
            }
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

final class QueueManager {
    var state: QueueState
    
    
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
