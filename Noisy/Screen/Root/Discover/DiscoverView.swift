//
//  DiscoverView.swift
//  Noisy
//
//  Created by Davor Lakus on 08.06.2023..
//

import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
        bodyView()
            .toolbar(content: toolbarContent)
    }
}

// MARK: - Body view
extension DiscoverView {
    func bodyView() -> some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Color.red400.ignoresSafeArea(edges: [.horizontal, .top])
        }
    }
}

// MARK: - Toolbar
extension DiscoverView {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        centeredTitle(.Tabs.discover)
    }
}
