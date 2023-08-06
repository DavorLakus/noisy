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
    case slideStarted
    case slideEnded(Double)
}

final class PlayerViewModel: ObservableObject {
    // MARK: - Published properties
    @Published var isPlaying = false
    @Published var timeControlStatus: AVPlayer.TimeControlStatus = .paused
    @Published var trackPosition: TimeInterval = .zero
    @Published var observedPosition: TimeInterval = .zero
    @Published var trackMaxPosition: TimeInterval = 29
    @Published var sliderState: PlayerSliderState = .reset
    @Published var currentTrack: Track?
    @Published var isOptionsSheetPresented = false
    @Published var isToastPresented = false

    // MARK: - Coordinator actions
    var onDidTapDismissButton: PassthroughSubject<Void, Never>?
    let onDidTapOptionsButton = PassthroughSubject<Void, Never>()
    let onDidTapQueueButton = PassthroughSubject<Void, Never>()
    let onDidTapShareButton = PassthroughSubject<Void, Never>()
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    
    // MARK: - Public properties
    var options: [OptionRow] = []
    var toastMessage: String = .empty
    let musicDetailsService: MusicDetailsService
    var queueManager: QueueManager
    
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Class lifecycle
    init(musicDetailsService: MusicDetailsService, queueManager: QueueManager) {
        self.musicDetailsService = musicDetailsService
        self.queueManager = queueManager
        
        bindQueueManager()
        currentTrack = queueManager.currentTrack.value
    }
}

// MARK: - Public extension
extension PlayerViewModel {
    
    func backButtonTapped() {
        onDidTapDismissButton?.send()
    }
    
    func addToFavoritesButtonTapped() {
        
    }
    
    func previousButtonTapped() {
        queueManager.onDidTapPreviousButton()
        trackPosition = .zero
    }

    func playPauseButtonTapped() {
        queueManager.onPlayPauseTapped()
    }
    
    func nextButtonTapped() {
        queueManager.onDidTapNextButton()
        trackPosition = .zero
    }
    
    func queueButtonTapped() {
        onDidTapQueueButton.send()
    }
    
    func shareButtonTapped() {
        onDidTapShareButton.send()
    }
    
    func optionsButtonTapped() {
        guard let currentTrack else { return }
        options = [addToQueueOption(currentTrack), viewAlbumOption(currentTrack), viewArtistOption(currentTrack)]
        withAnimation {
            isOptionsSheetPresented = true
        }
    }
}

// MARK: - Track options
private extension PlayerViewModel {
    func addToQueueOption(_ track: Track) -> OptionRow {
        let addToQueueSubject = PassthroughSubject<Void, Never>()
        
        addToQueueSubject
            .sink { [weak self] in
                self?.queueManager.append(track)
                self?.toastMessage = "\(track.name) \(String.Shared.addedToQueue)"
                withAnimation {
                    self?.isToastPresented = true
                }
            }
            .store(in: &cancellables)
        
        return OptionRow.addToQueue(action: addToQueueSubject)
    }
    
    func viewArtistOption(_ track: Track) -> OptionRow {
        let viewArtistSubject = PassthroughSubject<Void, Never>()
        
        viewArtistSubject
            .sink { [weak self] in
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
                self?.onDidTapArtistButton.send(track.artists[.zero])
            }
            .store(in: &cancellables)
        
        return OptionRow.viewArtist(action: viewArtistSubject)
    }
    
    func viewAlbumOption(_ track: Track) -> OptionRow {
        let viewAlbumSubject = PassthroughSubject<Void, Never>()
        
        viewAlbumSubject
            .sink { [weak self] in
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
                if let album = track.album {
                    self?.onDidTapAlbumButton.send(album)
                }
            }
            .store(in: &cancellables)
        
        return OptionRow.viewAlbum(action: viewAlbumSubject)
    }
}


// MARK: - Private extension
private extension PlayerViewModel {
    func bindQueueManager() {
        queueManager.isPlaying.assign(to: &_isPlaying.projectedValue)
        queueManager.trackPosition
            .sink { [weak self] position in
                withAnimation(.linear(duration: 0.5)) {
                    self?.trackPosition = position
                }
            }
            .store(in: &cancellables)
        queueManager.observedPosition.assign(to: &_observedPosition.projectedValue)
        queueManager.trackMaxPosition.assign(to: &_trackMaxPosition.projectedValue)
        queueManager.timeControlStatus.assign(to: &_timeControlStatus.projectedValue)
        $sliderState.sink { [weak self] state in
            self?.queueManager.sliderState.send(state)
        }
        .store(in: &cancellables)
        trackPosition = queueManager.state.currentTime
        queueManager.currentTrack
            .sink { [weak self] track in
                guard let track else { return }
                self?.currentTrack = track
            }
            .store(in: &cancellables)
        
        $currentTrack
            .sink { [weak self] track in
                guard let track else { return }
                self?.fetchTrackInfo(for: track.id)
            }
            .store(in: &cancellables)
    }
    
    func fetchTrackInfo(for trackId: String) {
        musicDetailsService.getTrack(with: trackId)
            .sink { [weak self] track in
                self?.currentTrack = track
            }
            .store(in: &cancellables)
    }
}
