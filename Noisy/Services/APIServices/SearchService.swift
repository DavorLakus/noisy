//
//  SearchService.swift
//  Noisy
//
//  Created by Davor Lakus on 06.06.2023..
//

import Foundation
import Combine

final class SearchService {
    // MARK: - Private properties
    private var cancellables = Set<AnyCancellable>()
    
    private let api: NoisyAPIProtocol
    
    // MARK: - Class lifecycle
    public init(api: NoisyAPIProtocol) {
        self.api = api
    }
}

extension SearchService {
    func search(for query: String, type: String, limit: Int, offset: Int) -> PassthroughSubject<SearchResult, Never> {
        let searchResponse = PassthroughSubject<SearchResult, Never>()
        
        api.search(for: query, type: type, limit: limit, offset: offset)
            .debugPrint()
            .decode(type: SearchResult.self, decoder: JSONDecoder())
            .sink(receiveCompletion: NetworkingManager.handleCompletion,
                  receiveValue: { result in
                searchResponse.send(result)
            })
            .store(in: &cancellables)
        
        return searchResponse
    }
}
