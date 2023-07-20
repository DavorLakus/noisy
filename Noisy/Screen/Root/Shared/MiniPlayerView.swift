//
//  MiniPlayerView.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import SwiftUI

final class MiniPlayerViewModel: ObservableObject {
    
}

struct MiniPlayerView: View {
    @State var isPlaying = false
    @State var queueState: QueueState
    
    var body: some View {
        bodyView()
    }
}

// MARK: - Body view
extension MiniPlayerView {
    func bodyView() -> some View {
        HStack {
            (isPlaying ? Image.Player.pause : Image.Player.play)
                .foregroundColor(.red600)
                .highPriorityGesture(playPauseGesture())
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(queueState.currentTrack.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(queueState.currentTrack.artists.first?.name ?? .empty)
                    .font(.nunitoSemiBold(size: 14))
                    .foregroundColor(.gray700)
                
            }
            Spacer()
        }
        .onTapGesture {
        }
    }
    
    func playPauseGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                isPlaying.toggle()
            }
    }
}
