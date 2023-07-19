//
//  AlbumRow.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI

struct AlbumRow: View {
    let album: EnumeratedSequence<[Album]>.Iterator.Element
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            Text("\(album.offset + 1)")
                .foregroundColor(.gray500)
                .font(.nunitoRegular(size: 14))
            LoadImage(url: URL(string: album.element.images.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: .zero) {
                Text(album.element.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text("\(String.Track.artist) \(album.element.items?.items.first?.artists.first?.name ?? .empty)")
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
    func albumRow(for album: EnumeratedSequence<[Album]>.Iterator.Element) -> some View {
        AlbumRow(album: album)
    }
}
