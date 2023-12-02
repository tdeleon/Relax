//
//  MockResponse.swift
//
//
//  Created by Thomas De Leon on 11/20/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Relax

/// A structure that represents a mock response.
///
/// A mocked response includes:
///
/// - An optional delay (the default is `0`s)
/// - An optional closure providing the request, which is called just before the response is returned. This can be used to validate the request.
/// - A closure providing the request and returning a ``Response``. This is used to provide the actual response back to the request.
///
/// ``Response``s consist of an `HTTPURLResponse`, `Data`, and optional `Error`. Convenience methods are provided to quickly create common
/// responses such as JSON objects, HTTP status codes, and Errors.
///
/// >Tip: To assist in validating requests, extension methods on `URLRequest` are [provided for convenience](<doc:Foundation/URLRequest>). These
/// methods utilize `XCTAssert` methods to validate values.
///
/// ```swift
/// // create a mock response returning a 204 HTTP status code
/// // implement the onReceive closure to validate the request properties
/// let mock = .mock { received in
///     XCTAssertEqual(recieved.httpMethod, "POST")
///     try received.validateQueryItems(match: [URLQueryItem(name: "filter", value: "true")]
/// }
///
public struct MockResponse {
    /// The delay before a response is returned.
    ///
    /// Any delay is applied *after* `onReceive` is called. The default value is `0` (no delay).
    public var delay: TimeInterval = 0
    /// Called just before the response is returned.
    ///
    /// Use this closure to validate what request was actually sent.
    public var onReceive: ((_ request: URLRequest) throws -> Void)? = nil
    /// A closure providing the response to be returned.
    public var responseHandler: (_ for: URLRequest) throws -> Response
    
    //MARK: - Mock Responses
    
    /// A mock response with the given status code, data, and optional error.
    /// - Parameters:
    ///   - statusCode: The HTTP status code to return. The default is `204` (no content).
    ///   - data: Data to return
    ///   - error: Error to return
    ///   - delay: A delay to wait after `onReceive` is called, but before the response is returned.
    ///   - onReceive: A closure called when the request is received, just before the response is returned. Use this to validate the request.
    /// - Returns: A new mock response
    ///
    /// Use this method when you don't need to base the response on the request received. A response will be created from the properties provided and
    /// returned.
    public static func mock(
        _ statusCode: Int = 204,
        data: Data = Data(),
        error: Error? = nil,
        delay: TimeInterval = 0,
        onReceive: ((_ received: URLRequest) throws -> Void)? = nil
    ) rethrows -> MockResponse {
        try mock(delay: delay, onReceive: onReceive) {
            Response(statusCode: statusCode, data: data, error: error, for: $0)
        }
    }
    
    /// A mock response with a closure providing the ``Response`` to be returned.
    /// - Parameters:
    ///   - delay: A delay to wait after `onReceive` is called, but before the response is returned.
    ///   - onReceive: A closure called when the request is received, just before the response is returned. Use this to validate the request.
    ///   - response: A closure which provides a response to `URLSession`, with a parameter of the request received.
    /// - Returns: A new mock response
    ///
    /// Use this method to provide a mock response when you need to base the response on the request received.
    public static func mock(
        delay: TimeInterval = 0,
        onReceive: ((_ received: URLRequest) throws -> Void)? = nil,
        response: @escaping (_ received: URLRequest) throws -> Response
    ) rethrows -> MockResponse {
        self.init(delay: delay, onReceive: onReceive) {
            try response($0)
        }
    }
    
    //MARK: Convenience Mocks
    
    /// A mock response returning an encodable model.
    /// - Parameters:
    ///   - model: The model to be returned
    ///   - encoder: The encoder to encode the model with
    ///   - statusCode: The HTTP status code to return. The default is `204` (no content).
    ///   - error: An error to return
    ///   - delay: A delay to wait after `onReceive` is called, but before the response is returned.
    ///   - onReceive: A closure called when the request is received, just before the response is returned. Use this to validate the request.
    /// - Returns: A new mock response.
    ///
    /// Use this method to return an `Encodable` model in the response as `Data`. The model will be encoded using the encoder specified.
    public static func mock<Model: Encodable>(
        _ model: Model,
        encoder: JSONEncoder = JSONEncoder(),
        statusCode: Int = 204,
        error: Error? = nil,
        delay: TimeInterval = 0,
        onReceive: ((_ received: URLRequest) throws -> Void)? = nil
    ) rethrows -> MockResponse {
        try mock(delay: delay, onReceive: onReceive) {
            try Response(model: model, encoder: encoder, statusCode: statusCode, error: error, for: $0)
        }
    }
    
    /// A mock response returning a JSON object.
    /// - Parameters:
    ///   - jsonObject: The json object to return
    ///   - jsonWritingOptions: Options for `JSONSerialization` writing
    ///   - statusCode: HTTP status code to return. The default is `204` (no content).
    ///   - error: Error to return
    ///   - delay: A delay to wait after `onReceive` is called, but before the response is returned.
    ///   - onReceive: A closure called when the request is received, just before the response is returned. Use this to validate the request.
    /// - Returns: A new mock response
    ///
    /// Use this method to return a mock response with the given json object as data. `JSONSerialization` will be used to encode the object.
    public static func mock(
        _ jsonObject: Any,
        jsonWritingOptions: JSONSerialization.WritingOptions = [],
        statusCode: Int = 204,
        error: Error? = nil,
        delay: TimeInterval = 0,
        onReceive: ((_ received: URLRequest) throws -> Void)? = nil
    ) throws -> MockResponse {
        try mock(delay: delay, onReceive: onReceive) { request in
            try Response(
                jsonObject: jsonObject,
                jsonWritingOptions: jsonWritingOptions,
                statusCode: statusCode,
                error: error,
                for: request
            )
        }
    }
    
    /// A mock response with the given HTTPURLResponse.
    /// - Parameters:
    ///   - httpURLResponse: The HTTPURLResponse to return
    ///   - data: Data to return
    ///   - error: Error to return
    ///   - delay: A delay to wait after `onReceive` is called, but before the response is returned.
    ///   - onReceive: A closure called when the request is received, just before the response is returned. Use this to validate the request.
    /// - Returns: A new mock response
    ///
    /// Creates a mock response using the HTTPURLResponse, data, and error provided.
    public static func mock(
        _ httpURLResponse: HTTPURLResponse,
        data: Data = Data(),
        error: Error? = nil,
        delay: TimeInterval = 0,
        onReceive: ((_ received: URLRequest) throws -> Void)? = nil
    ) rethrows -> MockResponse {
        try mock(delay: delay, onReceive: onReceive) { _ in
            { Response(httpURLResponse: httpURLResponse, data: data, error: error) }()
        }
    }
    
    //MARK: Error Mocks
    
    /// A mock response returning a `URLError` based on the given code
    /// - Parameters:
    ///   - urlErrorCode: The code of the error to return
    ///   - delay: A delay to wait after `onReceive` is called, but before the response is returned.
    ///   - onReceive: A closure called when the request is received, just before the response is returned. Use this to validate the request.
    /// - Returns: A new mock response
    ///
    /// Use this method to return a mock response with a `URLError` of the given code.
    public static func mock(
        _ urlErrorCode: URLError.Code,
        delay: TimeInterval = 0,
        onReceive: ((_ received: URLRequest) throws -> Void)? = nil
    ) rethrows -> MockResponse {
        try mock(delay: delay, onReceive: onReceive) { Response(code: urlErrorCode, for: $0) }
    }
    
    /// A mock response returning a `RequestError.HTTPError` of the given type
    /// - Parameters:
    ///   - httpErrorType: The type of HTTPError to return
    ///   - data: Data to return
    ///   - delay: A delay to wait after `onReceive` is called, but before the response is returned.
    ///   - onReceive: A closure called when the request is received, just before the response is returned. Use this to validate the request.
    /// - Returns: A new mock response
    ///
    /// Use this method to return a mock response with a `RequestError.HTTPError` of the given type.
    public static func mock(
        _ httpErrorType: RequestError.HTTPError.ErrorType,
        data: Data = Data(),
        delay: TimeInterval = 0,
        onReceive: ((_ received: URLRequest) throws -> Void)? = nil
    ) rethrows -> MockResponse {
        try mock(delay: delay, onReceive: onReceive) { Response(httpErrorType: httpErrorType, data: data, for: $0) }
    }
}
