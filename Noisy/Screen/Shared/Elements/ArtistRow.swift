//
//  ArtistRow.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI

struct ArtistRow: View {
    let artist: EnumeratedSequence<[Artist]>.Iterator.Element
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            Text("\(artist.offset + 1)")
                .foregroundColor(.gray500)
                .font(.nunitoRegular(size: 14))
            LoadImage(url: URL(string: artist.element.images?.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
            Text(artist.element.name)
                .foregroundColor(.gray700)
                .font(.nunitoBold(size: 16))
            Spacer()
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

extension View {
    func artistRow(for artist: EnumeratedSequence<[Artist]>.Iterator.Element) -> some View {
        ArtistRow(artist: artist)
    }
}