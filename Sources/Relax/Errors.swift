//
//  Errors.swift
//  
//
//  Created by Thomas De Leon on 5/13/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

//MARK: - Handling Errors
/// An error that occurs when making a `ServiceRequest`
///
/// This encapsulates errors while making a request (i.e. network connection issues), and does not include HTTP status  errors.
public enum RequestError: Error, Hashable {
    public static func ==(lhs: RequestError, rhs: RequestError) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(localizedDescription)
    }

    /// A   `URLError` occurred with the request
    case urlError(request: Request, error: URLError)
    /// A `DecodingError` occurred when decoding data from the request
    case decoding(request: Request, error: DecodingError)
    /// Other error occurred
    case other(request: Request, message: String)
    /// HTTP status code error
    case httpStatus(request: Request, error: HTTPError)
    
    public var localizedDescription: String {
        switch self {
        case .urlError(_, let error):
            return error.localizedDescription
        case .decoding(_, let error):
            return error.localizedDescription
        case .httpStatus(_, let error):
            return error.localizedDescription
        case .other(_, let message):
            return message
        }
    }
}

extension RequestError {
    /// An HTTP status code error
    ///
    /// Any HTTP status code which is considered an error- i.e. 3xx-5xx range
    public struct HTTPError: Error, Hashable {
        public static func ==(lhs: HTTPError, rhs: HTTPError) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(statusCode)
        }
        
        public enum ErrorType {
            /// 400 Bad request
            case badRequest
            /// 401 Unauthorized
            case unauthorized
            /// 403 Forbidden
            case forbidden
            /// 404 Not found
            case notFound
            /// 415 Unsupported media type
            case unsupportedMediaType
            /// 429 Too many requests
            case tooManyRequests
            /// 5XX Server error
            case server
            /// Other status (not 1XX-3XX)
            case other
        }
        
        /// The status code returned
        public let statusCode: Int
        /// The http error type
        public let type: ErrorType
        /// The response received
        public let response: Request.Response
        /// A localized description of the error
        public var localizedDescription: String {
            HTTPURLResponse.localizedString(forStatusCode: statusCode)
        }
        
        /// Create an HTTPError from a Response
        ///
        /// Creates an HTTPError for the given response based on the HTTP status code. Returns `nil` if no error (1XX-3XX status) occurred.
        /// - Parameter response: The response received
        public init?(response: Request.Response) {
            self.init(statusCode: response.urlResponse.statusCode, response: response)
        }
        
        internal init?(statusCode: Int, response: Request.Response) {
            switch statusCode {
            case 100...399:
                return nil
            case 400:
                self.type = .badRequest
            case 401:
                self.type = .unauthorized
            case 403:
                self.type = .forbidden
            case 404:
                self.type = .notFound
            case 415:
                self.type = .unsupportedMediaType
            case 429:
                self.type = .tooManyRequests
            case 500...599:
                self.type = .server
            default:
                self.type = .other
            }
            
            self.statusCode = statusCode
            self.response = response
        }
    }
}
