//
//  PlaylistRow.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI

struct PlaylistRow: View {
    let playlist: EnumeratedSequence<[Playlist]>.Iterator.Element
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            Text("\(playlist.offset + 1)")
                .foregroundColor(.gray500)
                .font(.nunitoRegular(size: 14))
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
                    .frame(maxHeight: .infinity)
            }
            Spacer()
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

extension View {
    func playlistRow(for playlist: EnumeratedSequence<[Playlist]>.Iterator.Element) -> some View {
        PlaylistRow(playlist: playlist)
    }
}
