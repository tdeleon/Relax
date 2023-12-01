//
//  RequestValidation.swift
//
//
//  Created by Thomas De Leon on 11/29/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

extension URLRequest {
    //MARK: Helper properties
    private var urlComponents: URLComponents? {
        guard let url else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }
    
    func bodyStreamData() -> Data? {
        guard let httpBodyStream else { return nil }
        httpBodyStream.open()
        let bufferSize = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()
        while httpBodyStream.hasBytesAvailable {
            let read = httpBodyStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: read)
        }
        buffer.deallocate()
        httpBodyStream.close()
        
        return data
    }
    
    /// The query items of the request
    public var queryItems: [URLQueryItem]? {
        guard let urlComponents else { return nil }
        return urlComponents.queryItems
    }
    
    //MARK: - Validation
    /// Validates the request query items match the provided query items
    /// - Parameter match: The expected query items
    ///
    /// This method validates that the query items match the expected using `XCTAssertEqual()`
    public func validateQueryItems(match expected: [URLQueryItem]) throws {
        let query = try XCTUnwrap(queryItems)
        XCTAssertEqual(query, expected)
        
    }
    /// Validates the request query items contain and/or do not contain the provided query item names
    /// - Parameters:
    ///   - contain: The names that the query items *must* include
    ///   - doNotContain: The names that the query items *must not* include
    public func validateQueryItemNames(contain: [String], doNotContain: [String] = []) throws {
        let query = try XCTUnwrap(queryItems)
        let names = Set(query.map(\.name))
        XCTAssertTrue(names.isSuperset(of: contain))
        XCTAssertTrue(names.intersection(doNotContain).isEmpty)
    }
    
    /// Validates the request body matches the provided data
    /// - Parameter expected: The expected data
    ///
    /// This method validates that the body matches the expected using `XCTAssertEqual()`
    public func validateBody(matches expected: Data) throws {
        let data = try XCTUnwrap(bodyStreamData())
        XCTAssertEqual(data, expected)
    }
    
    /// Validates the request body matches the provided `Codable` object
    /// - Parameters:
    ///   - matches: The Encodable object to match
    ///   - decoder: The decoder to use when decoding the request body data
    ///
    /// This method decodes the request body into the expected `Codable` type, then validates that it matches the expected object with
    /// `XCTAssertEqual()`.
    public func validateBody<Model>(
        matches expected: Model,
        decoder: JSONDecoder = JSONDecoder()
    ) throws where Model: Codable, Model: Equatable {
        let data = try XCTUnwrap(bodyStreamData())
        XCTAssertEqual(try decoder.decode(Model.self, from: data), expected)
    }
    
    /// Validates that the request body matches the provided dictionary
    /// - Parameter matches: The dictionary to match
    ///
    /// This method attempts to decode the request body using `JSONSerialization` into a dictionary, and then validates it against the expected using
    /// `XCTAssertEqual()`.
    ///
    /// Supported value types include:
    ///  - `String`
    ///  - `Bool`
    ///  - `Int`
    ///  - `Date`
    ///  - `Double`
    public func validateBody(matches expected: [String: Any]) throws {
        let data = try XCTUnwrap(bodyStreamData())
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        expected.keys.forEach {
            let expectedValue = expected[$0]
            let actualValue = json[$0]
            switch expectedValue {
            case is String:
                XCTAssertEqual(expectedValue as? String, actualValue as? String)
            case is Bool:
                XCTAssertEqual(expectedValue as? Bool, actualValue as? Bool)
            case is Int:
                XCTAssertEqual(expectedValue as? Int, actualValue as? Int)
            case is Date:
                XCTAssertEqual(expectedValue as? Date, actualValue as? Date)
            case is Double:
                XCTAssertEqual(expectedValue as? Double, actualValue as? Double)
            default:
                XCTFail("Unsupported value type")
                break
            }
        }
    }
    
    /// Validates that the request HTTP headers match the provided
    /// - Parameter match: The expected headers to match
    ///
    /// This method matches the request `allHTTPHeaderFields` with the expected using `XCTAssertEqual()`
    public func validateHeaders(match expected: [String: String]) {
        XCTAssertEqual(allHTTPHeaderFields, expected)
    }
    
    
    /// Validate that the request HTTP headers contain and/or do not contain the provided header names
    /// - Parameters:
    ///   - contain: Header names that `allHTTPHeaderFields` *must* contain
    ///   - doNotContain: Header names that `allHTTPHeaderFields` *must not* contain
    public func validateHeaderNames(contain: [String], doNotContain: [String] = []) {
        let names = Set(allHTTPHeaderFields?.map(\.key) ?? [])
        XCTAssertTrue(names.isSuperset(of: contain))
        XCTAssertTrue(names.intersection(doNotContain).isEmpty)
    }
}
