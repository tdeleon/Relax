//
//  Responses.swift
//  
//
//  Created by Thomas De Leon on 11/20/23.
//

import Foundation
import Relax

extension URLProtocolMock.MockResponse {
    /// A response from the given HTTP status code, data, and error
    /// - Parameters:
    ///   - statusCode: HTTP status code to return in the response's HTTPURLResponse
    ///   - data: Data to return
    ///   - error: Error to return
    ///   - request: The request this is in response to
    /// - Returns: A response from the given properties
    public static func response(
        statusCode: Int = 200,
        data: Data = Data(),
        error: Error? = nil,
        for request: URLRequest
    ) -> Response {
        let urlResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        if let requestError = error as? RequestError {
            return response(requestError, data: data)
        } else {
            return (urlResponse, data, error)
        }
    }

    //MARK: - Convenience Responses
    /// A response returning a model object as encoded json data
    /// - Parameters:
    ///   - model: The model to return
    ///   - encoder: The encoder to encode the model as JSON data
    ///   - statusCode: The HTTP status code to return
    ///   - error: Error to return
    ///   - request: The request this is in response to
    /// - Returns: A response from the given properties
    public static func response<Model: Encodable>(
        _ model: Model,
        encoder: JSONEncoder = JSONEncoder(),
        statusCode: Int = 200,
        error: Error? = nil,
        for request: URLRequest
    ) throws -> Response {
        let data = try encoder.encode(model)
        return response(statusCode: statusCode, data: data, for: request)
    }
    
    /// A response returning a JSON object as encoded data
    /// - Parameters:
    ///   - jsonObject: The object to encode
    ///   - jsonWritingOptions: Writing options to use
    ///   - statusCode: HTTP status code to return
    ///   - error: Error to return
    ///   - request: The request this is in response to
    /// - Returns: A response from the give properties
    public static func response(
        _ jsonObject: Any,
        jsonWritingOptions: JSONSerialization.WritingOptions = [],
        statusCode: Int = 200,
        error: Error? = nil,
        for request: URLRequest
    ) throws -> Response {
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: jsonWritingOptions)
        return response(statusCode: statusCode, data: data, for: request)
    }
    
    //MARK: Error Responses
    
    /// A response returning a `URLError` with the given code
    /// - Parameters:
    ///   - urlErrorCode: The code for the error
    ///   - request: The request this is in response to
    /// - Returns: A response with `URLError` of the given code
    public static func response(_ urlErrorCode: URLError.Code, for request: URLRequest) -> Response {
        response(error: URLError(urlErrorCode), for: request)
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
    public static func response(
        _ httpErrorType: RequestError.HTTPError.ErrorType,
        data: Data = Data(),
        for request: URLRequest
    ) -> Response {
        var status = 200
        switch httpErrorType {
        case .badRequest:
            status = 400
        case .unauthorized:
            status = 401
        case .forbidden:
            status = 403
        case .notFound:
            status = 404
        case .tooManyRequests:
            status = 429
        case .server:
            status = 500
        case .other:
            status = 405
        }
        return response(statusCode: status, for: request)
    }
    
    /// A response returning a `RequestError`
    /// - Parameters:
    ///   - requestError: The error to return
    ///   - data: Data to return
    /// - Returns: A response with the `RequestError` of the given type
    public static func response(_ requestError: RequestError, data: Data = Data()) -> Response {
        switch requestError {
        case .urlError(let request, let error):
            response(error.code, for: request.urlRequest)
        case .decoding(let request, let error):
            response(data: data, error: error, for: request.urlRequest)
        case .other(let request, let message):
            response(
                data: data,
                error: NSError(domain: "com.urlmock.test", code: -1, userInfo: [NSLocalizedDescriptionKey: message]),
                for: request.urlRequest
            )
        case .httpStatus(let request, let error):
            response(
                statusCode: error.statusCode, 
                data: data,
                for: request.urlRequest
            )
        }
    }
}
