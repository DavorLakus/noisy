//
//  VerticalCoordinatorProtocol.swift
//  Noisy
//
//  Created by Davor Lakus on 16.07.2023..
//

import SwiftUI

protocol CoordinatorProtocol: ObservableObject {
    associatedtype CoordinatorView: View
    func start() -> CoordinatorView
}

protocol VerticalCoordinatorProtocol: CoordinatorProtocol where CoordinatorView: CoordinatorViewProtocol {
    var navigationPath: NavigationPath { get set }
    associatedtype RootView: View
    associatedtype DetailView: View
    associatedtype DestinationPath: Hashable
    func start() -> CoordinatorView
    func push(_ path: DestinationPath)
    func pop()
    func rootView() -> RootView
    func navigationDestination(_ path: DestinationPath) -> DetailView
}

protocol CoordinatorViewProtocol: View {
    associatedtype Coordinator: VerticalCoordinatorProtocol
    var coordinator: Coordinator { get set }
}
