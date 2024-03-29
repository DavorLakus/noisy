//
//  NetworkingManager.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import SwiftUI

class NetworkingManager {
    public static let showError = PassthroughSubject<NoisyHTTPRouter, Never>()
    public static let showSpotifyError = PassthroughSubject<SpotifyError, Never>()
    public static let unauthorizedAccess = PassthroughSubject<Void, Never>()
    public static let invalidToken = PassthroughSubject<Void, Never>()
    public static let state = CurrentValueSubject<AppState, Never>(.loaded)
    
    static func performRequest(_ router: NoisyHTTPRouter) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: router.request)
            .handleEvents(receiveSubscription: loading, receiveOutput: loaded)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap({ try handleURLResponse(output: $0, router: router) })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func loading(_ subscription: Subscription) {
        DispatchQueue.main.async {
            withAnimation {
                state.send(.loading)
            }
        }
    }
    
    static func loaded(_ output: URLSession.DataTaskPublisher.Output) {
        DispatchQueue.main.async {
            withAnimation {
                state.send(.loaded)
            }
        }
    }
    
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, router: NoisyHTTPRouter) throws -> Data {
        guard let response = output.response as? HTTPURLResponse
        else { throw NetworkError.unknown }
        
        if response.statusCode < 200 || response.statusCode > 300 {
            debugPrint(response: response, router: router)
            if response.statusCode == 401 {
                unauthorizedAccess.send()
            }

            if case .token = router,
               response.statusCode == 400 {
                unauthorizedAccess.send()
            }
            
            if case .refreshToken = router,
               response.statusCode == 400 {
                invalidToken.send()
            }
            
            if let error = try? JSONDecoder().decode(SpotifyErrorResponse.self, from: output.data) {
                showSpotifyError.send(error.error)
            }
//            throw NetworkError.badURLResponse(router: router, statusCode: response.statusCode)
        }
        
        return output.data
    }
    
    static func debugPrint(response: HTTPURLResponse, router: NoisyHTTPRouter) {
        if response.statusCode < 200 || response.statusCode > 300 {
            print("failure: \(router.path), method: \(router.method) code: \(response.statusCode)")
        } else {
            print("success: \(router.path), method: \(router.method) code: \(response.statusCode)")
        }
    }
    
    public static func handleCompletion(completion: Subscribers.Completion<Error>) {
        DispatchQueue.main.async {
            withAnimation {
                state.send(.loaded)
            }
        }
        
        switch completion {
        case .finished:
            break
        case .failure(let error):
            if let networkError = error as? NetworkError {
                switch networkError {
                case .badURLResponse(let router, let statusCode):
                    handleBadURLResponse(for: router, statusCode: statusCode)
                case .unknown:
                    print("unknown")
                }
            }
            print(error)
        }
    }
    
    static func handleBadURLResponse(for router: NoisyHTTPRouter, statusCode: Int) {
        switch router {
        default:
            break
        }
    }
}

struct SpotifyErrorResponse: Codable {
    let error: SpotifyError
}

struct SpotifyError: Codable, Identifiable {
    let status: Int
    let message: String
    
    var id: Int { status }
}
