//
//  AnyPublisher+Extension.swift
//  Noisy
//
//  Created by Davor Lakus on 30.05.2023..
//

import Combine
import Foundation

extension AnyPublisher where Output == Data {
 func debugPrint() -> AnyPublisher<Output, Failure> {
     handleEvents(receiveOutput: { result in
         Swift.print(result)
         Swift.print(result.prettyPrintedJSONString ?? String.empty)
     })
     .eraseToAnyPublisher()
 }
}
