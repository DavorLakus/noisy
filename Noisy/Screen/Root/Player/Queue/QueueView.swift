//
//  QueueView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct QueueView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State var trackRowWidth: CGFloat = .zero
    
    var body: some View {
        bodyView()
            .toolbar(content: toolbarContent)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Body
extension QueueView {
    func bodyView() -> some View {
        ZStack {
            Color.green400
                .ignoresSafeArea()
            
            queueList()
        }
    }
    
    func queueList() -> some View {
        List {
            ForEach(Array(viewModel.queueManager.state.tracks.enumerated()), id: \.offset) { enumeratedTrack in
                TrackRow(track: enumeratedTrack, isEnumerated: false)
                    .listRowBackground(Color.green400)
                    .listRowSeparator(.hidden)
                    .padding(Constants.spacing)
                    .readSize { trackRowWidth = $0.width }
                    .background {
                        if enumeratedTrack.element == viewModel.queueManager.state.currentTrack {
                            Color.green200
                                .offset(x: -trackRowWidth + viewModel.currentTime / 29 * trackRowWidth )
                        }
                    }
                    .cardBackground(backgroundColor: .appBackground, hasShadow: false)
                    .swipeActions(allowsFullSwipe: true) {
                        Button {
                            viewModel.trackRowSwiped(enumeratedTrack)
                        } label: {
                            Text(String.Shared.remove)
                        }
                        .tint(.red300)
                    }
            }
            .onMove(perform: viewModel.moveTrack)
        }
        .background { Color.green400 }
        .listStyle(.plain)
    }
}

// MARK: - Toolbar
extension QueueView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        leadingToolbarButton()
        centeredTitle(.Player.currentQueue, color: .appBackground)
    }
    
    @ToolbarContentBuilder
    func leadingToolbarButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: viewModel.backButtonTapped) {
                Image.Shared.chevronLeft
                    .foregroundColor(.appBackground)
            }
        }
    }
}
