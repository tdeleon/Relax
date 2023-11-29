//
//  Responses.swift
//  
//
//  Created by Thomas De Leon on 11/20/23.
//

import Foundation
import Relax

extension URLMock.MockResponse {
    /// A structure defining the actual response provided to a `URLSession`
    public struct Response {
        /// `HTTPURLResponse` to return.
        public var httpURLResponse: HTTPURLResponse
        /// `Data` to be returned. The default is empty data (`Data()`).
        public var data: Data
        /// `Error` to be returned. The default is `nil`.
        public var error: Error?
        
        //MARK: - Creating Responses
        
        /// Create a response with an `HTTPURLResponse`
        /// - Parameters:
        ///   - httpURLResponse: `HTTPURLResponse` to return
        ///   - data: `Data` to return
        ///   - error: `Error` to return
        public init(_ httpURLResponse: HTTPURLResponse, data: Data = Data(), error: Error? = nil) {
            self.httpURLResponse = httpURLResponse
            self.data = data
            self.error = error
        }
        
        /// A response from the given HTTP status code, data, and error
        /// - Parameters:
        ///   - statusCode: HTTP status code to return in the response's HTTPURLResponse. The default is `204` (no content).
        ///   - data: Data to return
        ///   - error: Error to return
        ///   - request: The request this is in response to
        /// - Returns: A response from the given properties
        public init(_ statusCode: Int = 204, data: Data = Data(), error: Error? = nil, for request: URLRequest) {
            let urlResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            if let requestError = error as? RequestError {
                self.init(requestError, data: data)
            } else {
                self.init(urlResponse, data: data, error: error)
            }
        }
        
        //MARK: - JSON Responses
        /// A response returning a model object as encoded json data
        /// - Parameters:
        ///   - model: The model to return.
        ///   - encoder: The encoder to encode the model as JSON data.
        ///   - statusCode: The HTTP status code to return. The default is `204` (no content).
        ///   - error: Error to return.
        ///   - request: The request this is in response to.
        /// - Returns: A response from the given properties.
        public init<Model: Encodable>(
            _ model: Model,
            encoder: JSONEncoder = JSONEncoder(),
            statusCode: Int = 204,
            error: Error? = nil,
            for request: URLRequest
        ) throws {
            let data = try encoder.encode(model)
            self.init(statusCode, data: data, error: error, for: request)
        }
        
        /// A response returning a JSON object as encoded data
        /// - Parameters:
        ///   - jsonObject: The object to encode
        ///   - jsonWritingOptions: Writing options to use
        ///   - statusCode: HTTP status code to return
        ///   - error: Error to return
        ///   - request: The request this is in response to
        /// - Returns: A response from the give properties
        public init(
            _ jsonObject: Any,
            jsonWritingOptions: JSONSerialization.WritingOptions = [],
            statusCode: Int = 200,
            error: Error? = nil,
            for request: URLRequest
        ) throws {
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: jsonWritingOptions)
            self.init(statusCode, data: data, error: error, for: request)
        }
        
        //MARK: Error Responses
        
        /// A response returning a `URLError` with the given code
        /// - Parameters:
        ///   - urlErrorCode: The code for the error
        ///   - request: The request this is in response to
        /// - Returns: A response with `URLError` of the given code
        public init(_ urlErrorCode: URLError.Code, for request: URLRequest) {
            self.init(error: URLError(urlErrorCode), for: request)
        }
        
        /// A response returning a `RequestError.HTTPError`
        /// - Parameters:
        ///   - httpErrorType: The type of HTTPError to return
        ///   - data: Data to return
        ///   - request: The request this is in response to
        /// - Returns: A response with a `RequestError.HTTPError` of the given type
        ///
        /// - Note: The `Request.send()` method will only throw/return an error if the  `Request.Configuration.parseHTTPStatusErrors`
        /// property is set to `true`. If  `false`, the the status code will be set in the HTTPURLResponse, but the method will not throw.
        public init(
            _ httpErrorType: RequestError.HTTPError.ErrorType,
            data: Data = Data(),
            for request: URLRequest
        ) {
            var statusCode: Int
            switch httpErrorType {
            case .badRequest:
                statusCode = 400
            case .unauthorized:
                statusCode = 401
            case .forbidden:
                statusCode = 403
            case .notFound:
                statusCode = 404
            case .tooManyRequests:
                statusCode = 429
            case .server:
                statusCode = 500
            case .other:
                statusCode = 405
            }
            self.init(statusCode, data: data, for: request)
        }
        
        /// A response returning a `RequestError`
        /// - Parameters:
        ///   - requestError: The error to return
        ///   - data: Data to return
        /// - Returns: A response with the `RequestError` of the given type
        public init(_ requestError: RequestError, data: Data = Data()) {
            switch requestError {
            case .urlError(let request, let error):
                self.init(error.code, for: request.urlRequest)
            case .decoding(let request, let error):
                self.init(data: data, error: error, for: request.urlRequest)
            case .other(let request, let message):
                self.init(
                    data: data,
                    error: NSError(domain: "com.urlmock.test", code: -1, userInfo: [NSLocalizedDescriptionKey: message]),
                    for: request.urlRequest
                )
            case .httpStatus(let request, let error):
                self.init(error.statusCode, data: data, for: request.urlRequest)
            }
        }
        
    }
}
