//
//  Request+SendPublisher.swift
//  
//
//  Created by Thomas De Leon on 7/25/22.
//

#if canImport(Combine)
import Foundation
import Combine

extension Request {
    /**
     Response for an HTTP request using a Combine publisher
     
        - `request`: The request made
        - `response`: The response received
        - `data`: Data received
     */
    public typealias PublisherResponse = (request: Request, response: HTTPURLResponse, data: Data)
    
    public typealias PublisherModelResponse<Model: Decodable> = (request: Request, response: HTTPURLResponse, responseModel: Model)
    
    /// <#Description#>
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - parseHTTPStatusErrors: <#parseHTTPStatusErrors description#>
    /// - Returns: <#description#>
    public func send(
        session: URLSession = .shared,
        parseHTTPStatusErrors: Bool = false
    ) -> AnyPublisher<PublisherResponse, RequestError> {
        Future<PublisherResponse, RequestError> { promise in
            send(
                session: session,
                autoResumeTask: true,
                parseHTTPStatusErrors: parseHTTPStatusErrors) { result in
                    switch result {
                    case .success(let successResponse):
                        promise(.success(successResponse))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - decoder: <#decoder description#>
    ///   - session: <#session description#>
    ///   - parseHTTPStatusErrors: <#parseHTTPStatusErrors description#>
    /// - Returns: <#description#>
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared,
        parseHTTPStatusErrors: Bool = false
    ) -> AnyPublisher<ResponseModel, RequestError> {
        send(session: session, parseHTTPStatusErrors: parseHTTPStatusErrors)
            .map(\.data)
            .decode(type: ResponseModel.self, decoder: decoder)
            .mapError { RequestError.decoding(request: self, error: $0 as! DecodingError) }
            .eraseToAnyPublisher()
    }
}
#endif
