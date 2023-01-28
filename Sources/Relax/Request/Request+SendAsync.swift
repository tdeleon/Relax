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
    
    /// Response for an HTTP request sent asynchronously, decoding a Decodable instance
    ///
    /// - Parameters:
    ///    - request: The request made
    ///    - urlResponse: The response received
    ///    - responseModel: The model decoded from received data
    public typealias AsyncModelResponse<Model: Decodable> = (request: Request, urlResponse: HTTPURLResponse, responseModel: Model)
    
    /// Send a request asynchronously
    ///
    /// - Parameters:
    ///   - session: The session to use (default is `URLSession.shared`
    ///   - parseHTTPStatusErrors: Whether to parse HTTP status codes returned for errors. The default is `false`.
    /// - Returns: A response containing the request sent, url response, and data.
    /// - Throws: A `RequestError` on error.
    @discardableResult
    public func send(
        session: URLSession = .shared,
        parseHTTPStatusErrors: Bool = false
    ) async throws -> AsyncResponse {
        var task: URLSessionDataTask?
        let onCancel = { task?.cancel() }
        
        return try await withTaskCancellationHandler {
            try Task.checkCancellation()
            
            return try await withCheckedThrowingContinuation { continuation in
                task = send(
                    session: session,
                    autoResumeTask: true,
                    parseHTTPStatusErrors: parseHTTPStatusErrors) { result in
                        switch result {
                        case .success(let success):
                            continuation.resume(returning: success)
                        case .failure(let failure):
                            continuation.resume(throwing: failure)
                        }
                    }
            }
        } onCancel: {
            onCancel()
        }
    }
    
    /// Send a request asynchronously, decoding data received to a Decodable instance.
    /// - Parameters:
    ///   - decoder: The decoder to decode received data with. Default is `JSONDecoder()`.
    ///   - session: The session to use to send the request. Default is `URLSession.shared`.
    ///   - parseHTTPStatusErrors: Whether to parse HTTP status codes returned for errors. The default is `false`.
    /// - Returns: The model, decoded from received data.
    /// - Throws: A `RequestError` on error.
    public func send<ResponseModel: Decodable>(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared,
        parseHTTPStatusErrors: Bool = false
    ) async throws -> ResponseModel {
        let response: AsyncResponse = try await send(
            session: session,
            parseHTTPStatusErrors: parseHTTPStatusErrors
        )
        do {
            return try decoder.decode(ResponseModel.self, from: response.data)
        } catch {
            throw RequestError.decoding(request: self, error: error as! DecodingError)
        }
    }
}
