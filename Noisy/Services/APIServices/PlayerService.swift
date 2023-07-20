//
//  PlayerService.swift
//  Noisy
//
//  Created by Davor Lakus on 18.07.2023..
//

import Foundation
import Combine

final class PlayerService {
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    private let api: NoisyAPIProtocol
    
    // MARK: - Class lifecycle
    public init(api: NoisyAPIProtocol) {
        self.api = api
    }
}
