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

    var background: Color {
        .appBackground
    }

    var body: some View {
        VStack(spacing: .zero) {
            SearchBar(isActive: $viewModel.searchIsActive, query: $viewModel.query)
                .frame(height: 40)
                .padding(.horizontal, Constants.margin)
                .padding(.vertical, 8)
                .background { Color.cmxWhite }
            
            switch viewModel.state {
            case .loading:
                Color.cmxWhite
            case .loaded:
                loadedStateView()
            case .empty:
                emptyStateView()
            }
        }
        .toolbar {
            leadingLargeTitle(title: String.Tabs.search)
            accountButton(avatar: .avatar, action: viewModel.accountButtonTapped)
        }
        .onAppear(perform: viewModel.pullToRefresh)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(viewModel.searchIsActive ? .hidden : .visible, for: .navigationBar)
        .background(background)
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
                    .font(.poppinsSemiBold16)
                Text(String.Employees.emptyStateDescription)
                    .font(.poppinsRegular14)
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
            
            List {
                ForEach(viewModel.presentedEmployees, id: \.id) { employee in
                    employeeCard(for: employee)
                }
                Spacer()
                    .frame(height: 120)
                    .listRowBackground(background)
                    .listRowSeparator(.hidden)
            }
            .padding(.top, 24)
            .listStyle(.plain)
            .refreshable(action: viewModel.pullToRefresh)
        }
        .zStackTransition(.opacity)
    }
    
    @ViewBuilder
    func filteringButtons() -> some View {
        VStack(spacing: 0) {
            navigationBarBottomBorder()
            
            HStack(spacing: Constants.margin) {
                filteringButton(title: String.Employees.selectDepartment, image: .filter, flexible: true, badgeToggled: !viewModel.filteringOptions.isEmpty) {
                    viewModel.filterButtonTapped()
                }
                .sheet(isPresented: $viewModel.isFilterPresented) {
                    FilterSheetView(viewModel: viewModel, isSheetPresented: $viewModel.isFilterPresented, isSort: false)
                        .presentationDetents([.fraction(0.9), .fraction(0.9)])
        //                .interactiveDismissDisabled(true)
                        .presentationDragIndicator(.hidden)
                }

                filteringButton(title: String.Employees.sortBy, image: .sort, badgeToggled: viewModel.sortingOption != .name) {
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
                .font(.poppinsSemiBold14)
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
    func employeeCard(for employee: Employee) -> some View {
        VStack(spacing: 13.5) {
            employeeCardRow(label: String.Employees.name, value: employee.name, isHighlightable: true)
            employeeCardRow(label: String.Employees.surname, value: employee.surname, isHighlightable: true)
            employeeCardRow(label: String.Employees.department, value: employee.departmentName)
            employeeCardRow(label: String.Employees.lead, value: viewModel.getTeamLeadName(for: employee.teamLeadId) ?? .noData)
        }
        .padding(16)
        .cardBackground(borderColor: .gray100)
        .listRowBackground(background)
        .listRowSeparator(.hidden)
        .onTapGesture { viewModel.employeeRowSelected(employee) }
    }
    
    @ViewBuilder
    func employeeCardRow(label: String, value: String, isHighlightable: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.poppinsSemiBold12)
                .foregroundColor(.gray500)
            Spacer()
            
            Group {
                if isHighlightable {
                    highlightedText(value, query: viewModel.query)
                } else {
                    Text(value)
                }
            }
            .font(.poppinsRegular14)
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
                            .fill(Color.universalMint)
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
