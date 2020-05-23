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
public enum RequestError: Error, Equatable {
    /// Bad request (HTTP status 400)
    case httpBadRequest(request: URLRequest)
    /// Unauthorized (HTTP status 401)
    case httpUnauthorized(request: URLRequest)
    /// Not found (HTTP status 404)
    case httpNotFound(request: URLRequest)
    /// Server error occured (HTTP status 500-599
    case httpServerError(request: URLRequest, httpStatus: Int)
    /// Another HTTP error status code occurred (besides 400, 401, 404, and outside the 200-399 success code range)
    case otherHTTPError(request: URLRequest, httpStatus: Int)
    /// A   `URLError` occurred with the request
    case urlError(request: URLRequest, error: URLError)
    /// Another error occurred
    case other(request: URLRequest, message: String)
    
    init?(httpStatusCode: Int, request: URLRequest) {
        switch httpStatusCode {
        case 100...399:
            return nil
        case 400:
            self = .httpBadRequest(request: request)
        case 401:
            self = .httpUnauthorized(request: request)
        case 404:
            self = .httpNotFound(request: request)
        case 500...599:
            self = .httpServerError(request: request, httpStatus: httpStatusCode)
        default:
            self = .otherHTTPError(request: request, httpStatus: httpStatusCode)
        }
    }
}
