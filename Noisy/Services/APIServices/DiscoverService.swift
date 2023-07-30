//
//  DiscoverService.swift
//  Noisy
//
//  Created by Davor Lakus on 06.06.2023..
//

import Foundation
import Combine

final class DiscoverService {
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    private let api: NoisyAPIProtocol
    
    // MARK: - Class lifecycle
    public init(api: NoisyAPIProtocol) {
        self.api = api
    }
}

extension DiscoverService {
    func discover(seedParameters: [URLQueryItem]) -> PassthroughSubject<RecommendationResult, Never> {
        let discoverResults = PassthroughSubject<RecommendationResult, Never>()
        
        api.discover(parameters: seedParameters)
            .decode(type: RecommendationResult.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion,
                  receiveValue: { result in
                discoverResults.send(result)
            })
            .store(in: &cancellables)
        
        return discoverResults
    }
    
    func getRecommendationGenres() -> PassthroughSubject<[String], Never> {
        let genres = PassthroughSubject<[String], Never>()
        
        api.getRecommendationGenres()
            .decode(type: GenresResult.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion,
                  receiveValue: { result in
                genres.send(result.genres)
            })
            .store(in: &cancellables)
        
        return genres
    }
}
