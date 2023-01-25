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
    /**
     Response for an async HTTP request
     
        - `request`: The request made
        - `response`: The response received
        - `data`: Data received
     */
    public typealias AsyncResponse = (request: Request, response: HTTPURLResponse, data: Data)
    
    public typealias AsyncModelResponse<Model: Decodable> = (request: Request, response: HTTPURLResponse, responseModel: Model)
    
    @discardableResult
    /// <#Description#>
    /// - Parameters:
    ///   - session: <#session description#>
    ///   - parseHTTPStatusErrors: <#parseHTTPStatusErrors description#>
    /// - Returns: <#description#>
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
