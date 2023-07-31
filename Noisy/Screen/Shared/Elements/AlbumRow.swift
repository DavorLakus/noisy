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
    let action: ((Album) -> Void)?
    
    init(album: EnumeratedSequence<[Album]>.Iterator.Element, isEnumerated: Bool = true, action:((Album) -> Void)? = nil) {
        self.album = album
        self.isEnumerated = isEnumerated
        self.action = action
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
                .shadow(radius: 4)
            VStack(alignment: .leading, spacing: .zero) {
                Text(album.element.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(album.element.artists?.first?.name ?? .empty)
                    .foregroundColor(.gray700)
                    .font(.nunitoSemiBold(size: 14))
            }
            Spacer()
            
            if let action {
                Button {
                    action(album.element)
                } label: {
                    Image.Shared.threeDots
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

extension View {
    func albumRow(for album: EnumeratedSequence<[Album]>.Iterator.Element, optionsAction: ((Album) -> Void)? = nil) -> some View {
        AlbumRow(album: album, action: optionsAction)
    }
}
