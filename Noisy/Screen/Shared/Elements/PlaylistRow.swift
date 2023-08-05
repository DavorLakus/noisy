//
//  PlaylistRow.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI

struct PlaylistRow: View {
    let playlist: EnumeratedSequence<[Playlist]>.Iterator.Element
    let isEnumerated: Bool
    let action: ((Playlist) -> Void)?
    
    init(playlist: EnumeratedSequence<[Playlist]>.Iterator.Element, isEnumerated: Bool = true, action: ((Playlist) -> Void)? = nil) {
        self.playlist = playlist
        self.isEnumerated = isEnumerated
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            if isEnumerated {
                Text("\(playlist.offset + 1)")
                    .foregroundColor(.gray500)
                    .font(.nunitoRegular(size: 14))
            }
            
            LoadImage(url: URL(string: playlist.element.images?.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: .zero) {
                Text(playlist.element.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text("\(String.Home.total) \(playlist.element.tracks.total)")
                    .foregroundColor(.gray700)
                    .font(.nunitoSemiBold(size: 14))
            }
            Spacer()
            
            if let action {
                Button {
                    action(playlist.element)
                } label: {
                    Image.Shared.threeDots
                }
            }
        }
        .background { Color.white }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

extension View {
    func playlistRow(for playlist: EnumeratedSequence<[Playlist]>.Iterator.Element, optionsAction: ((Playlist) -> Void)? = nil) -> some View {
        PlaylistRow(playlist: playlist, action: optionsAction)
    }
}
