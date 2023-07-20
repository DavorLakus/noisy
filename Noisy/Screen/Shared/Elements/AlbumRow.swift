//
//  AlbumRow.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI

struct AlbumRow: View {
    let album: EnumeratedSequence<[Album]>.Iterator.Element
    let isEnumerated: Bool
    
    init(album: EnumeratedSequence<[Album]>.Iterator.Element, isEnumerated: Bool = true) {
        self.album = album
        self.isEnumerated = isEnumerated
    }
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            if isEnumerated {
                Text("\(album.offset + 1)")
                    .foregroundColor(.gray500)
                    .font(.nunitoRegular(size: 14))
            }
            
            LoadImage(url: URL(string: album.element.images.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: .zero) {
                Text(album.element.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(album.element.artists?.first?.name ?? .empty)
                    .foregroundColor(.gray700)
                    .font(.nunitoSemiBold(size: 14))
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
