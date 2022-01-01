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
        guard let urlRequest = URLRequest(request: request, baseURL: baseURL) else {
            return Fail<PublisherResponse, RequestError>(error: .urlError(request: URLRequest(url: baseURL), error: URLError(.badURL)))
                .eraseToAnyPublisher()
        }
        // Create a data task publisher
        return session.dataTaskPublisher(for: urlRequest)
        // Convert the output to `RelaxPublisherResponse`, check for http errors
            .mapError { RequestError.urlError(request: urlRequest, error: $0) }
            .tryMap { output -> PublisherResponse in
                let response = output.response as! HTTPURLResponse
                
                if let httpError = RequestError(httpStatusCode: response.statusCode, request: urlRequest) {
                    throw httpError
                }
                
                return (urlRequest, response, output.data)
            }
            .mapError { $0 as? RequestError ?? RequestError.other(request: urlRequest, message: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
}
#endif
