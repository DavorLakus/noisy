//
//  MiniPlayerView.swift
//  Noisy
//
//  Created by Davor Lakus on 20.07.2023..
//

import SwiftUI

struct MiniPlayerView: View {
    @State var isPlaying = false
    @State var queueManager: QueueState
    
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
                Text(queueManager.currentTrack.name)
                    .foregroundColor(.gray700)
                    .font(.nunitoBold(size: 16))
                Text(queueManager.currentTrack.artists.first?.name ?? .empty)
                    .font(.nunitoSemiBold(size: 14))
                    .foregroundColor(.gray700)
                
            }
            Spacer()
        }
    }
    
    func playPauseGesture() -> some Gesture {
        TapGesture()
            .onEnded {
                isPlaying.toggle()
            }
    }
}
