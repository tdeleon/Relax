//
//  RequestValidation.swift
//
//
//  Created by Thomas De Leon on 11/29/23.
//

import Foundation
import XCTest

extension URLRequest {
    //MARK: Helper properties
    private var urlComponents: URLComponents? {
        guard let url else { return nil }
        return URLComponents(url: url, resolvingAgainstBaseURL: true)
    }
    
    public var queryItems: [URLQueryItem]? {
        guard let urlComponents else { return nil }
        return urlComponents.queryItems
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
    
    //MARK: - Validation
    public func validate(queryItems expected: [URLQueryItem]) throws {
        let query = try XCTUnwrap(queryItems)
        XCTAssertEqual(expected, query)
        
    }
    public func validate(queryItemNames matching: [String], notMatching: [String] = []) throws {
        let query = try XCTUnwrap(queryItems)
        let names = Set(query.map(\.name))
        XCTAssertTrue(names.isSuperset(of: matching))
        XCTAssertTrue(names.intersection(notMatching).isEmpty)
    }
    
    public func validate(body expected: Data) throws {
        let data = try XCTUnwrap(bodyStreamData())
        XCTAssertEqual(data, expected)
    }
    
    public func validate<Model>(
        body: Model,
        decoder: JSONDecoder = JSONDecoder()
    ) throws where Model: Codable, Model: Equatable {
        let data = try XCTUnwrap(bodyStreamData())
        XCTAssertEqual(try decoder.decode(Model.self, from: data), body)
    }
    
    public func validate(body: [String: Any]) throws {
        let data = try XCTUnwrap(bodyStreamData())
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        body.keys.forEach {
            let expectedValue = body[$0]
            let actualValue = json?[$0]
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
                break
            }
        }
    }
    
    public func validate(headers expected: [String: String]) {
        XCTAssertEqual(allHTTPHeaderFields, expected)
    }
    
    public func validate(headerNames matching: [String], notMatching: [String]) {
        let names = Set(allHTTPHeaderFields?.map(\.key) ?? [])
        XCTAssertTrue(names.isSuperset(of: matching))
        XCTAssertTrue(names.intersection(notMatching).isEmpty)
    }
}
