//
//  QueueManager.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import AVKit
import Combine
import SwiftUI

final class QueueManager: ObservableObject {
    var state = QueueState(tracks: [])
    var player = AVPlayer()
    let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(1000))
    
    var sliderState = CurrentValueSubject<PlayerSliderState, Never>(.reset)
    
    let trackPosition = CurrentValueSubject<TimeInterval, Never>(0)
    let observedPosition = CurrentValueSubject<TimeInterval, Never>(.zero)
    let trackMaxPosition = CurrentValueSubject<TimeInterval, Never>(30)
    let isPlaying = CurrentValueSubject<Bool, Never>(false)
    let timeControlStatus = CurrentValueSubject<AVPlayer.TimeControlStatus, Never>(.paused)
    
    private var itemDurationKVOPublisher: AnyCancellable?
    private var timeControlStatusKVOPublisher: AnyCancellable?
    var periodicTimeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        trackPosition.send(state.currentTime)
        bindPlayer()
        bindSliderState()
    }
    
    func setState(with track: Track) {
        state.tracks = [track]
        state.currentTrack = track
        state.currentTime = .zero
    }
    
    func bindSliderState() {
        sliderState.sink { [weak self] state in
            switch state {
            case .reset: break
            case .slideStarted: break
            case .slideEnded(let seekTime):
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
        } else if let urlString = state.currentTrack?.previewUrl,
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
    
    func onDidTapNextButton() {
        play(track: state.next())
    }
    
    func onDidTapPreviousButton() {
        if trackPosition.value < 1 {
            play(track: state.previous())
        } else {
            state.currentTime = .zero
            play(track: state.currentTrack)
        }
    }
    
    func remove(_ track: EnumeratedSequence<[Track]>.Element) {
        if state.tracks.count > 1 {
            state.tracks.remove(at: track.offset)
            if track.offset == state.currentTrackIndex {
                state.currentTrackIndex =  state.currentTrackIndex > 0 ? state.currentTrackIndex - 1 : 0
                state.currentTrack = state.tracks[state.currentTrackIndex]
                state.currentTime = .zero
                play(track: state.currentTrack)
            }
        }
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
                if newStatus == .paused,
                   trackPosition.value + 0.2 > trackMaxPosition.value {
                    trackPosition.send(.zero)
                    self.play(track: self.state.next())
                }
                self.timeControlStatus.send(newStatus)
            }
    }
    
    func bindItemDuration() {
        itemDurationKVOPublisher = player
            .publisher(for: \.currentItem?.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newStatus in
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
            
            switch self.sliderState.value {
            case .reset:
                if time.seconds != 0 {
                    self.trackPosition.send(time.seconds)
                }
            case .slideStarted:
                break
            case .slideEnded(let seekTime):
                withAnimation {
                    self.state.currentTime = seekTime
                    self.sliderState.send(.reset)
                    self.trackPosition.send(seekTime)
                }
            }
        }
    }
}
