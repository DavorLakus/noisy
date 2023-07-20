//
//  TrackRow.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI
struct TrackRow: View {
    let track: EnumeratedSequence<[Track]>.Iterator.Element
    let isEnumerated: Bool
    
    init(track: EnumeratedSequence<[Track]>.Iterator.Element, isEnumerated: Bool = true) {
        self.track = track
        self.isEnumerated = isEnumerated
    }
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            if isEnumerated {
                Text("\(track.offset + 1)")
                    .foregroundColor(.gray500)
                    .font(.nunitoRegular(size: 14))
            }
            
            LoadImage(url: URL(string: track.element.album.images.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(track.element.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(track.element.artists.first?.name ?? .empty)
                    .foregroundColor(.gray700)
                    .font(.nunitoSemiBold(size: 14))
                
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

extension View {
    func trackRow(for track: EnumeratedSequence<[Track]>.Iterator.Element) -> some View {
        TrackRow(track: track)
    }
}
