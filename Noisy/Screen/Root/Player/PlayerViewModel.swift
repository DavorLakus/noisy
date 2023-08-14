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
    @Published var isSaved = false

    // MARK: - Coordinator actions
    var onDidTapDismissButton: PassthroughSubject<Void, Never>?
    let onDidTapOptionsButton = PassthroughSubject<Void, Never>()
    let onDidTapQueueButton = PassthroughSubject<Void, Never>()
    let onDidTapShareButton = PassthroughSubject<Void, Never>()
    let onDidTapArtistButton = PassthroughSubject<Artist, Never>()
    let onDidTapAlbumButton = PassthroughSubject<Album, Never>()
    let onDidTapAddToPlaylist = PassthroughSubject<[Track], Never>()
    
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
    
    func currentTrackArists() -> String {
        currentTrack?.artists.compactMap({ $0.name }).joined(separator: ", ") ?? .empty
    }
    
    func addToFavoritesButtonTapped() {
        isSaved ? removeFromSaved() : addToSaved()
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
        options = [addToQueueOption(currentTrack), viewAlbumOption(currentTrack), viewArtistOption(currentTrack), addToPlaylistOption(currentTrack)]
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
    
    func addToPlaylistOption(_ track: Track) -> OptionRow {
        let addToPlaylistSubject = PassthroughSubject<Void, Never>()
        
        addToPlaylistSubject
            .sink { [weak self] in
                self?.onDidTapAddToPlaylist.send([track])
                withAnimation {
                    self?.isOptionsSheetPresented = false
                }
            }
            .store(in: &cancellables)
        
        return OptionRow.addToPlaylist(action: addToPlaylistSubject)
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
                if let albumImages = self?.currentTrack?.album?.images,
                   !albumImages.isEmpty {
                    guard let self,
                          let currentTrack = self.currentTrack,
                          track.id != currentTrack.id
                    else { return }
                }
                self?.currentTrack = track
                self?.fetchTrackInfo(for: track.id)
                self?.checkIfTrackSaved(id: track.id)
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
    
    func checkIfTrackSaved(id: String) {
        musicDetailsService.checkSavedTracks(with: id)
            .sink { [weak self] isSaved in
                self?.isSaved = isSaved[0]
            }
            .store(in: &cancellables)
    }
    
    func addToSaved() {
        guard let currentTrack else { return }
        musicDetailsService.saveTracks(with: currentTrack.id)
            .sink { [weak self] isSaved in
                self?.checkIfTrackSaved(id: currentTrack.id)
                self?.toastMessage = "\(currentTrack.name) \(String.Shared.addedToFavorites)"
                withAnimation {
                    self?.isToastPresented = true
                }
            }
            .store(in: &cancellables)
    }
    
    func removeFromSaved() {
        guard let currentTrack else { return }
        musicDetailsService.removeTracks(with: currentTrack.id)
            .sink { [weak self] isSaved in
                self?.checkIfTrackSaved(id: currentTrack.id)
                self?.toastMessage = "\(currentTrack.name) \(String.Shared.removedFromFavorites)"
                withAnimation {
                    self?.isToastPresented = true
                }
            }
            .store(in: &cancellables)
    }
}
