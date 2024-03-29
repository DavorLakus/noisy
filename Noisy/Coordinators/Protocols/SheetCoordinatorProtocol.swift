//
//  SheetCoordinatorProtocol.swift
//  Noisy
//
//  Created by Davor Lakus on 14.08.2023..
//

import SwiftUI

protocol SheetCoordinatorProtocol: CoordinatorProtocol where CoordinatorView: CoordinatorViewProtocol {
    associatedtype SheetView: View
    associatedtype SheetPath: Hashable
    var sheetPath: SheetPath { get set }
    var isSheetPresented: Bool { get set }
    func presentSheetView() -> SheetView
}

protocol SheetCoordinatorViewProtocol: CoordinatorViewProtocol where Coordinator: SheetCoordinatorProtocol {
    var coordinator: Coordinator { get set }
}
