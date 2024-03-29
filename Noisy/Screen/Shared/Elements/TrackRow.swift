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
    let showAlbumImage: Bool
    let tint: Color
    let action: ((Track) -> Void)?
    
    init(track: EnumeratedSequence<[Track]>.Iterator.Element, isEnumerated: Bool = true, showAlbumImage: Bool = true, tint: Color = .gray700, action: ((Track) -> Void)? = nil) {
        self.track = track
        self.isEnumerated = isEnumerated
        self.showAlbumImage = showAlbumImage
        self.tint = tint
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            if isEnumerated {
                Text("\(track.offset + 1)")
                    .foregroundColor(.gray500)
                    .font(.nunitoRegular(size: 14))
            }
            
            if showAlbumImage {
                LoadImage(url: URL(string: track.element.album?.images.first?.url ?? .empty))
                    .scaledToFit()
                    .cornerRadius(18)
                    .frame(width: 36, height: 36)
                    .shadow(radius: 2)
            }
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(track.element.name)
                    .foregroundColor(tint)
                    .lineLimit(1)
                    .font(.nunitoBold(size: 16))
                Text(track.element.artists.first?.name ?? .empty)
                    .foregroundColor(tint)
                    .font(.nunitoSemiBold(size: 14))
            }
            Spacer()
            
            if let action {
                Button {
                    action(track.element)
                } label: {
                    Image.Shared.threeDots
                        .foregroundColor(tint)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

extension View {
    func trackRow(for track: EnumeratedSequence<[Track]>.Iterator.Element, optionsAction: ((Track) -> Void)? = nil) -> some View {
        TrackRow(track: track, action: optionsAction)
    }
}
