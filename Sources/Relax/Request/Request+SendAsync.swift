//
//  Request+SendAsync.swift
//  
//
//  Created by Thomas De Leon on 7/25/22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


extension Request {
    /// Response for an HTTP request sent asynchronously
    ///
    /// - Parameters:
    ///    - request: The request made
    ///    - urlResponse: The response received
    ///    - data: Data received. If there is no data in the response, then this will be 0 bytes.
    public typealias AsyncResponse = (request: Request, urlResponse: HTTPURLResponse, data: Data)
    
    /// Send a request asynchronously
    ///
    /// - Parameters:
    ///   - session: When set, overrides the ``Request/session`` used to send the request.
    /// - Returns: A response containing the request sent, url response, and data.
    /// - Throws: A `RequestError` on error.
    @discardableResult
    public func send(session: URLSession? = nil) async throws -> AsyncResponse {
        try Task.checkCancellation()
        do {
            let response = try await (session ?? self.session).data(for: urlRequest)
            return try handleURLSessionResponse(response)
        } catch let error as URLError {
            throw RequestError.urlError(request: self, error: error)
        } catch let error as RequestError {
            throw error
        } catch {
            throw RequestError.other(request: self, message: error.localizedDescription)
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
        let response: AsyncResponse = try await send(session: session)
        do {
            return try (decoder ?? self.decoder).decode(ResponseModel.self, from: response.data)
        } catch let error as DecodingError {
            throw RequestError.decoding(request: self, error: error)
        } catch {
            throw error
        }
    }
}
