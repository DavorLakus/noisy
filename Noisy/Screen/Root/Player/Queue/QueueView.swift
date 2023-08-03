//
//  QueueView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct QueueView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State var trackRowSize: CGSize
    @State var trackRowOffsets: [CGFloat]
    
    init(viewModel: QueueViewModel) {
        self.viewModel = viewModel
        trackRowSize = .zero
        trackRowOffsets = [CGFloat](repeating: .zero, count: viewModel.queueManager.state.tracks.count)
    }
    
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
                    .padding(Constants.spacing)
                    .readSize { trackRowSize = $0 }
                    .background {
                        if enumeratedTrack.element == viewModel.queueManager.state.currentTrack {
                            Color.green200
                                .offset(x: -trackRowSize.width + viewModel.currentTime / 29 * trackRowSize.width )
                        }
                    }
                    .cardBackground(backgroundColor: .appBackground, borderColor: .gray300, hasShadow: false)
                    .offset(x: trackRowOffsets[enumeratedTrack.offset])
                    .swipeAction(title: String.Shared.remove, gradient: [.red400, .red300], height: trackRowSize.height, offset: $trackRowOffsets[enumeratedTrack.offset]) {
                        withAnimation(.linear(duration: 1)) {
                            viewModel.trackRowSwiped(enumeratedTrack)
                        }
                        trackRowOffsets = [CGFloat](repeating: .zero, count: viewModel.queueManager.state.tracks.count)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.green400)
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
