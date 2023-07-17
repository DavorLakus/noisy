//
//  SearchView.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @GestureState var gestureOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: .zero) {
            SearchBar(isActive: $viewModel.searchIsActive, query: $viewModel.query)
                .frame(height: 40)
                .padding(.horizontal, Constants.margin)
                .padding(.vertical, 8)
                .background { Color.appBackground }
            
            switch viewModel.state {
            case .loading:
                Color.appBackground
            case .loaded:
                loadedStateView()
            }
        }
        .toolbar {
            leadingLargeTitle(title: String.Tabs.search)
            accountButton(avatar: LoadImage(url: URL(string: viewModel.profile?.images.first?.url ?? .empty)), action: viewModel.accountButtonTapped)
        }
        .onAppear(perform: viewModel.pullToRefresh)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Toolbar components
private extension SearchView {
    @ToolbarContentBuilder
    func searchNavigationBarItem() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            SearchBar(isActive: $viewModel.searchIsActive, query: $viewModel.query)
        }
    }
}

// MARK: - Body
private extension SearchView {
    @ViewBuilder
    func emptyStateView() -> some View {
        VStack(spacing: 16) {
            Group {
                Text(String.Employees.emptyStateTitle)
                    .font(.nunitoSemiBold(size: 16))
                Text(String.Employees.emptyStateDescription)
                    .font(.nunitoRegular(size: 14))
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.gray700)
        }
        .refreshGesture(offset: $gestureOffset, action: viewModel.pullToRefresh)
        .padding(Constants.margin)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .zStackTransition(.opacity)
    }
    
    @ViewBuilder
    func loadedStateView() -> some View {
        Group {
            if !viewModel.searchIsActive {
                filteringButtons()
            }
            
//            List {
//                ForEach(viewModel.presentedTracks, id: \.id) { track in
//                    trackCard(for: track)
//                }
//                Spacer()
//                    .frame(height: 120)
//                    .listRowBackground(background)
//                    .listRowSeparator(.hidden)
//            }
//            .padding(.top, 24)
//            .listStyle(.plain)
////            .refreshable(action: viewModel.pullToRefresh)
        }
        .zStackTransition(.opacity)
    }
    
    @ViewBuilder
    func filteringButtons() -> some View {
        VStack(spacing: 0) {
            navigationBarBottomBorder()
            
            HStack(spacing: Constants.margin) {
                filteringButton(title: String.Employees.selectDepartment, image: .Shared.filter, flexible: true, badgeToggled: !viewModel.filteringOptions.isEmpty) {
                    viewModel.filterButtonTapped()
                }
                .sheet(isPresented: $viewModel.isFilterPresented) {
                    FilterSheetView(viewModel: viewModel, isSheetPresented: $viewModel.isFilterPresented, isSort: false)
                        .presentationDetents([.fraction(0.9), .fraction(0.9)])
                        .presentationDragIndicator(.hidden)
                }

                filteringButton(title: String.Employees.sortBy, image: .Shared.sort, badgeToggled: viewModel.sortingOption != .name) {
                    viewModel.sortingButtonTapped()
                }
                .sheet(isPresented: $viewModel.isSortPresented) {
                    FilterSheetView(viewModel: viewModel, isSheetPresented: $viewModel.isSortPresented, isSort: true)
                        .presentationDetents([.fraction(0.45), .fraction(0.45)])
        //                .interactiveDismissDisabled(true)
                        .presentationDragIndicator(.hidden)
                }
            }
            .padding(.horizontal, Constants.margin)
            .padding(.top, 24)
        }
    }
    
    @ViewBuilder
    func filteringButton(title: String, image: Image, flexible: Bool = false, badgeToggled: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.nunitoSemiBold(size: 14))
                .foregroundColor(.gray600)
            image
                .foregroundColor(.gray400)
        }
        .frame(maxWidth: flexible ? .infinity : nil)
        .background(Color.appBackground)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(RoundedRectangle(cornerRadius: Constants.smallCornerRadius).stroke(Color.gray400))
        .mintBadge(isPresented: badgeToggled)
    }
    
    @ViewBuilder
    func trackCard(for track: Track) -> some View {
        VStack(spacing: 13.5) {
            trackCardRow(label: String.Track.name, value: track.name, isHighlightable: true)
            trackCardRow(label: String.Track.artist, value: track.artists.first?.name ?? .noData, isHighlightable: true)
        }
//        .cardBackground()
//        .padding(16)
//        .listRowBackground(background)
//        .listRowSeparator(.hidden)
//        .onTapGesture { viewModel.track(employee) }
    }
    
    @ViewBuilder
    func trackCardRow(label: String, value: String, isHighlightable: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.nunitoSemiBold(size: 12))
                .foregroundColor(.gray500)
            Spacer()
            
            Group {
                if isHighlightable {
                    highlightedText(value, query: viewModel.query)
                } else {
                    Text(value)
                }
            }
            .font(.nunitoRegular(size: 14))
            .foregroundColor(.gray700)
        }
    }
}

extension View {
    @ViewBuilder
    func mintBadge(isPresented: Bool) -> some View {
        ZStack {
            if isPresented {
                ZStack(alignment: .topTrailing) {
                    self
                    Group {
                        Rectangle()
                            .fill(Color.appBackground)
                            .frame(width: 10, height: 10)
                        Circle()
                            .fill(Color.green200)
                            .frame(width: 8, height: 8)
                    }
                    .offset(x: 1.5, y: -1.5)
                }
                .transition(.opacity)
            } else {
                self
                    .transition(.opacity)
            }
        }
    }
}
