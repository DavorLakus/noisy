//
//  PlaylistsView.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import SwiftUI

struct PlaylistsView: View {
    @ObservedObject var viewModel: PlaylistsViewModel
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
                .randomCirclesOverlay(count: 1)
                .opacity(0.5)
            VStack {
                headerView()
                bodyView()
            }
        }
        .dynamicModalSheet(isPresented: $viewModel.isCreateNewSheetPresented, content: createNewPlaylistSheet)
        .toast(isPresented: $viewModel.isToastPresented, message: viewModel.toastMessage)
        .onAppear(perform: viewModel.viewDidAppear)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Body view
extension PlaylistsView {
    func headerView() -> some View {
        HStack {
            Text(String.Shared.addToPlaylist)
                .foregroundColor(.gray700)
                .font(.nunitoBold(size: 26))
            Spacer()
            Button(action: viewModel.doneButtonTapped) {
                Text(String.Shared.done)
                    .font(.nunitoBold(size: 19))
                    .foregroundColor(.gray700)
            }
        }
        .padding(Constants.margin)
    }
    
    func bodyView() -> some View {
        ScrollView {
            VStack(spacing: Constants.margin) {
                LargeButton(foregroundColor: .gray700, backgroundColor: .yellow300, padding: 8, title: String.Shared.createNew, action: viewModel.createNewSheetToggle)
                    .padding(.horizontal, Constants.mediumIconSize)
                ForEach(Array(viewModel.playlists.enumerated()), id: \.offset) { enumeratedPlaylist in
                    HStack {
                        (viewModel.selectedPlaylists.contains(enumeratedPlaylist.element) ? Image.Shared.checkboxFill : Image.Shared.checkbox)
                            .foregroundColor(.purple600)
                        PlaylistRow(playlist: enumeratedPlaylist, isEnumerated: false)
                    }
                    .zStackTransition(.slide)
                    .background { Color.appBackground.opacity(0.1) }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        viewModel.playlistRowTapped(for: enumeratedPlaylist.element)
                    }
                }
            }
            .padding(Constants.margin)
        }
    }
}

// MARK: - Create new sheet
extension PlaylistsView {
    func createNewPlaylistSheet() -> some View {
        sheetBody()
            .background {
                Color.appBackground.ignoresSafeArea()
                    .circleOverlay(xOffset: 0.1, yOffset: -0.3, frameMultiplier: 0.6, color: .yellow400)
                    .circleOverlay(xOffset: -0.2, yOffset: -0.2, frameMultiplier: 1.0, color: .yellow200)
            }
    }
    
    func sheetBody() -> some View {
        VStack {
            sheetHeader()
            sheetForm()
        }
        .padding(Constants.margin)
    }
    
    func sheetHeader() -> some View {
        HStack {
            Text(String.Shared.createNewPlaylist)
                .font(.nunitoBold(size: 22))
                .foregroundColor(.gray700)
            Spacer()
            Button(action: viewModel.createNewSheetToggle) {
                Image.Shared.close
                    .foregroundColor(.gray600)
            }
        }
    }
    
    func sheetForm() -> some View {
        VStack(alignment: .leading) {
            Text(String.Shared.title)
                .font(.nunitoBold(size: 17))
                .foregroundColor(.gray600)
            
            TextField(String.Shared.createNew, text: $viewModel.newPlaylistTitle)
                .font(.nunitoSemiBold(size: 19))
                .foregroundColor(.gray800)
                .padding(.vertical, 4)
                .bottomBorder()
                .padding(.vertical, 8)
            
            Button(action: viewModel.savePlaylistTapped) {
                Text(String.Shared.save)
                    .font(.nunitoBold(size: 17))
                    .foregroundColor(.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: Constants.cornerRadius).fill(Color.green400)
                    }
            }
            .opacity(viewModel.newPlaylistTitle.isEmpty ? 0.6 : 1.0)
            .disabled(viewModel.newPlaylistTitle.isEmpty)
        }
        .padding(Constants.margin)
        .cardBackground()
        .padding(.bottom, 80)
    }
}
