//
//  OptionsView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI
import Combine

enum OptionRow: Identifiable {
    case addToQueue(action: PassthroughSubject<Void, Never>)
    case addToSpotifyQueue(action: PassthroughSubject<Void, Never>)
    case viewArtist(action: PassthroughSubject<Void, Never>)
    case viewAlbum(action: PassthroughSubject<Void, Never>)
    case addToPlaylist(action: PassthroughSubject<Void, Never>)
    
    var icon: Image {
        switch self {
        case .addToQueue:
            return .Shared.addToQueue
        case .addToSpotifyQueue:
            return .Shared.addToSpotifyQueue
        case .viewArtist:
            return .Shared.artist
        case .viewAlbum:
            return .Shared.album
        case .addToPlaylist:
            return .Shared.playlist
        }
    }
    
    var title: String {
        switch self {
        case .addToQueue:
            return .Shared.addToQueue
        case .addToSpotifyQueue:
            return .Shared.addToSpotifyQueue
        case .viewArtist:
            return .Shared.viewArtist
        case .viewAlbum:
            return .Shared.viewAlbum
        case .addToPlaylist:
            return .Shared.addToPlaylist
        }
    }
    
    var id: String {
        switch self {
        case .addToQueue:
            return "addToQueue"
        case .addToSpotifyQueue:
            return "addToSpotifyQueue"
        case .viewArtist:
            return "viewArtist"
        case .viewAlbum:
            return "viewAlbum"
        case .addToPlaylist:
            return "addToPlaylist"
        }
    }
}

struct OptionsView: View {
    @Binding var isPresented: Bool
    let options: [OptionRow]
    
    var body: some View {
        bodyView()
            .background {
                Color.yellow100.ignoresSafeArea()
                    .circleOverlay(xOffset: 0.5, yOffset: 0.0, frameMultiplier: 0.8)
            }
    }
}

// MARK: - Body view
extension OptionsView {
    func bodyView() -> some View {
        VStack(alignment: .trailing, spacing: .zero) {
            Button {
                withAnimation {
                    isPresented = false
                }
            } label: {
                Text(String.Shared.done)
                    .foregroundColor(.green500)
                    .font(.nunitoBold(size: 18))
            }
            .padding([.top, .trailing], Constants.margin)
            
            LazyVStack(spacing: Constants.margin) {
                ForEach(options) { option in
                    optionRow(for: option)
                }
            }
            .padding(Constants.margin)
            .padding(.bottom, 30)
        }
        
    }
    
    func optionRow(for optionRow: OptionRow) -> some View {
        Button {
            switch optionRow {
            case .addToQueue(let action), .addToSpotifyQueue(let action), .viewAlbum(let action), .viewArtist(let action), .addToPlaylist(let action):
                action.send()
            }
        } label: {
            HStack(spacing: 24) {
                optionRow.icon
                Text(optionRow.title)
                    .font(.nunitoSemiBold(size: 20))
                    .foregroundColor(.gray600)
                Spacer()
            }
        }
        .padding(.horizontal, Constants.margin)
        .background(.clear)
    }
}
