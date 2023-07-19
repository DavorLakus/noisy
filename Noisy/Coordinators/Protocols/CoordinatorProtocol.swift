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
