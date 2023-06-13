//
//  HomeService.swift
//  Noisy
//
//  Created by Davor Lakus on 06.06.2023..
//

import Foundation
import Combine

final class HomeService {
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    private let api: NoisyAPIProtocol
    
    // MARK: - Class lifecycle
    public init(api: NoisyAPIProtocol) {
        self.api = api
    }
}

// MARK: - Public extension
extension HomeService {
    func getProfile() -> PassthroughSubject<Profile, Never> {
        let user = PassthroughSubject<Profile, Never>()
        
        api.getProfile()
            .debugPrint()
            .decode(type: Profile.self, decoder: JSONDecoder())
            .sink(
                receiveCompletion: NetworkingManager.handleCompletion,
                receiveValue: { [weak self]  in
print($0)
                })
            .store(in: &cancellables)
        
        return user
    }
}
