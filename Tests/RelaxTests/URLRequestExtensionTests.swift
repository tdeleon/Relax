//
//  URLRequestExtensionTests.swift
//  
//
//  Created by Thomas De Leon on 12/28/21.
//

#if !os(watchOS)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

final class URLRequestExtensionTests : XCTestCase {
    
    func testInitRequest() throws {
        let request = ExampleService.Get()
        let urlRequest = try XCTUnwrap(URLRequest(request: request, baseURL: ExampleService().baseURL))
        XCTAssertEqual(urlRequest, request.urlRequest)
    }
    
    func testInitRequestFail() throws {
        XCTAssertNil(URLRequest(request: ExampleService.Get(), baseURL: URL(string: "a://@@")!))
    }
    
    func testInitInvalidBaseURL() throws {
        let url = URL(string: "a://@@")!
        XCTAssertNil(URLRequest(type: .get, baseURL: url))
    }
    
    func testInitPathBase() throws {
        let url = URL(string: "example")!
        let request = URLRequest(type: .get, baseURL: url)
        XCTAssertEqual(request?.url, url)
    }
    
    func testEndpointPath() throws {
        let url = URL(string: "https://example.com/api")!
        let endpoint = "/example/second"
        let request = URLRequest(type: .get, baseURL: url, endpointPath: endpoint)
        let expectedURL = url.appendingPathComponent(endpoint)
        XCTAssertEqual(request?.url, expectedURL)
    }
    
    func testEndpointPathTrailingSlash() throws {
        let url = URL(string: "https://example.com/api/")!
        let endpoint = "/example/second"
        let request = URLRequest(type: .get, baseURL: url, endpointPath: endpoint)
        let expectedURL = url.appendingPathComponent(String(endpoint.dropFirst()))
        XCTAssertEqual(request?.url, expectedURL)
    }
    
    func testInitAppendPath() throws {
        let url = URL(string: "https://example.com/path1")!
        let pathToAdd = ["path2", "path3"]
        let request = URLRequest(type: .get, baseURL: url, pathComponents: pathToAdd)
        let expectedURL = url.appendingPathComponent(pathToAdd.joined(separator: "/"))
        XCTAssertEqual(request?.url, expectedURL)
    }
    
    func testEndpointAndPathComponents() throws {
        let url = URL(string: "https://example.com/path1")!
        let endpoint = "endpoint"
        let pathToAdd = ["path2", "path3"]
        let request = URLRequest(type: .get, baseURL: url, endpointPath: endpoint, pathComponents: pathToAdd)
        let expectedURL = url.appendingPathComponent(([endpoint]+pathToAdd).joined(separator: "/"))
        XCTAssertEqual(request?.url, expectedURL)
    }
    
    func testInitQueryParameters() throws {
        let url = URL(string: "https://example.com")!
        let parameters = [URLQueryItem(name: "key", value: "value")]
        
        var expectedComponents = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        expectedComponents.queryItems = parameters
        let expectedURL = try XCTUnwrap(expectedComponents.url)
        
        let requestURL = try XCTUnwrap(URLRequest(type: .get, baseURL: url, queryParameters: parameters)?.url)
        XCTAssertEqual(requestURL, expectedURL)
    }
    
    func testInitExistingQueryParameters() throws {
        let url = URL(string: "https://example.com?key1=value1")!
        let parameters = [URLQueryItem(name: "key2", value: "value2")]
        
        var expectedComponents = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        expectedComponents.queryItems?.append(contentsOf: parameters)
        let expectedURL = try XCTUnwrap(expectedComponents.url)
        
        let requestURL = try XCTUnwrap(URLRequest(type: .get, baseURL: url, queryParameters: parameters)?.url)
        XCTAssertEqual(requestURL, expectedURL)
    }
    
    func testInitHeadersDefaultContentType() {
        let defaultContentTypeHeader = [URLRequest.contentTypeHeaderField: RequestContentType.applicationJSON.rawValue]
        let url = URL(string: "https://example.com")!
        let headers = ["Header1": "value1"]
        let request = URLRequest(type: .get, baseURL: url, headers: headers)
        XCTAssertEqual(request?.allHTTPHeaderFields, headers.merging(defaultContentTypeHeader, uniquingKeysWith: { (current, _) in current }))
    }
    
    func testInitDefaultContentType() {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(type: .get, baseURL: url)
        XCTAssertEqual(request?.allHTTPHeaderFields, [URLRequest.contentTypeHeaderField: RequestContentType.applicationJSON.rawValue])
    }
    
    func testInitContentTypeApplicationJSON() throws {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(type: .get, baseURL: url, contentType: .applicationJSON)
        XCTAssertEqual(request?.allHTTPHeaderFields, [URLRequest.contentTypeHeaderField: RequestContentType.applicationJSON.rawValue])
    }
    
    func testInitContentTypeTextPlain() throws {
        let url = URL(string: "https://example.com")!
        let request = URLRequest(type: .get, baseURL: url, contentType: .textPlain)
        XCTAssertEqual(request?.allHTTPHeaderFields, [URLRequest.contentTypeHeaderField: RequestContentType.textPlain.rawValue])
    }
    
}
#endif
