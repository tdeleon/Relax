//
//  Request+Send.swift
//  
//
//  Created by Thomas De Leon on 7/25/22.
//

import Foundation
#if canImport(FoundationNetworking)
@preconcurrency import FoundationNetworking
#endif


extension Request {
    /// Response for an HTTP request sent asynchronously
    ///
    /// - Parameters:
    ///    - request: The request made
    ///    - urlResponse: The response received
    ///    - data: Data received. If there is no data in the response, then this will be 0 bytes.
    public typealias Response = (request: Request, urlResponse: HTTPURLResponse, data: Data)
    
    /// Send a request asynchronously
    ///
    /// - Parameters:
    ///   - session: When set, overrides the ``Request/session`` used to send the request.
    /// - Returns: A response containing the request sent, url response, and data.
    /// - Throws: A `RequestError` on error.
    @discardableResult
    public func send(
        session: URLSession? = nil
    ) async throws -> Response {
        let received = try await (session ?? self.session).data(for: urlRequest)
        guard let httpResponse = received.1 as? HTTPURLResponse else {
            throw RequestError.urlError(request: self, error: URLError(.unknown))
        }
        
        let requestResponse = (self, httpResponse, received.0)
        
        if configuration.parseHTTPStatusErrors, let httpError = RequestError.HTTPError(response: requestResponse) {
            throw httpError
        } else {
            return requestResponse
        }
    }
    
    /// Send a request asynchronously, decoding data received to a Decodable instance.
    /// - Parameters:
    ///   - decoder: When set, overrides the ``Request/decoder`` used to decode received data.
    ///   - session: When set, overrides the ``Request/session`` used to send the request.
    /// - Returns: The model, decoded from received data.
    /// - Throws: A `RequestError` on error.
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder? = nil,
        session: URLSession? = nil
    ) async throws -> ResponseModel {
        let response: Response = try await send(session: session)
        do {
            return try (decoder ?? self.decoder).decode(ResponseModel.self, from: response.data)
        } catch let error as DecodingError {
            throw RequestError.decoding(request: self, error: error)
        } catch {
            throw error
        }
    }
}
