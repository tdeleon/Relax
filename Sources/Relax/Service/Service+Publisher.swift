//
//  Service+Publisher.swift
//  
//
//  Created by Thomas De Leon on 1/1/22.
//

#if canImport(Combine)
import Foundation
import Combine

extension Service {
    /**
     Make a request using a Combine publisher.
     - Parameters:
        - request: The request to execute
        - session: The session to use. If not specified, the default provided by the `session` property of the `Service` will be used
     - Returns: A Combine publisher of type `PublisherResponse`.
     */
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func request<Request: ServiceRequest>(_ request: Request, session: URLSession=session) -> AnyPublisher<PublisherResponse, RequestError> {
        
        return Future<PublisherResponse, RequestError> { promise in
            self.request(request, session: session) { result in
                switch result {
                case .success(let successResponse):
                    guard let data = successResponse.data else {
                        promise(.failure(.other(request: URLRequest(url: baseURL), message: "No data was returned")))
                        return
                    }
                    promise(.success((successResponse.request, successResponse.response, data)))
                case .failure(let failure):
                    promise(.failure(failure))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
#endif
