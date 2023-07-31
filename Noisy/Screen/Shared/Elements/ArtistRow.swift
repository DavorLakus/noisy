//
//  ArtistRow.swift
//  Noisy
//
//  Created by Davor Lakus on 19.07.2023..
//

import SwiftUI

struct ArtistRow: View {
    let artist: EnumeratedSequence<[Artist]>.Iterator.Element
    let isEnumerated: Bool
    let action: ((Artist) -> Void)?
    
    init(artist: EnumeratedSequence<[Artist]>.Iterator.Element, isEnumerated: Bool = true, action: ((Artist) -> Void)? = nil) {
        self.artist = artist
        self.isEnumerated = isEnumerated
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: Constants.margin) {
            if isEnumerated {
                Text("\(artist.offset + 1)")
                    .foregroundColor(.gray500)
                    .font(.nunitoRegular(size: 14))
            }
            
            LoadImage(url: URL(string: artist.element.images?.first?.url ?? .empty))
                .scaledToFit()
                .cornerRadius(18)
                .frame(width: 36, height: 36)
                .shadow(radius: 2)
            Text(artist.element.name)
                .foregroundColor(.gray700)
                .font(.nunitoBold(size: 16))
            Spacer()
         
            if let action {
                Button {
                    action(artist.element)
                } label: {
                    Image.Shared.threeDots
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

extension View {
    func artistRow(for artist: EnumeratedSequence<[Artist]>.Iterator.Element, optionsAction: ((Artist) -> Void)? = nil) -> some View {
        ArtistRow(artist: artist, action: optionsAction)
    }
}
