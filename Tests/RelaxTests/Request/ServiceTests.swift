//
//  ServiceTests.swift
//  
//
//  Created by Thomas De Leon on 1/25/23.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

final class ServiceTests: XCTestCase {
    typealias Complex = ExampleService.ComplexRequests
    typealias SubComplex = ExampleService.ComplexRequests.SubComplex

    func testBasic() {
        let basic = ExampleService.get
        XCTAssertEqual(basic._properties, .empty)
        XCTAssertEqual(basic.httpMethod, .get)
        XCTAssertEqual(basic.url, ExampleService.baseURL)
    }
    
    func testNested() {
        let complex = ExampleService.ComplexRequests.complex
        let expectedURL = ExampleService.baseURL
            .appendingPathComponent(Complex.path)
            .appending(complex._properties.pathComponents)
        
        XCTAssertEqual(complex.url, expectedURL)
        XCTAssertEqual(complex._properties.headers.value, Complex.sharedProperties.headers.value)
    }
    
    func testDoubleNested() {
        let request = SubComplex.sub
        
        let expectedURL = ExampleService.baseURL
            .appendingPathComponent(Complex.path)
            .appendingPathComponent(SubComplex.path)
        
        XCTAssertEqual(request.url, expectedURL)
        XCTAssertEqual(request._properties, SubComplex.allProperties)
        
        XCTAssertEqual(SubComplex.allProperties, Complex.sharedProperties + SubComplex.sharedProperties)
    }
    
    func testConfiguration() {
        let request = ExampleService.ConfigTest.request
        
        XCTAssertTrue(request.configuration.parseHTTPStatusErrors)
    }

    func testDefaults() {
        enum Testing: APIComponent {
            static let baseURL = URL(string: "https://example.com")!
        }
        
        XCTAssertEqual(Testing.allProperties, .empty)
        XCTAssertEqual(Testing.configuration, .default)
        XCTAssertEqual(Testing.session, .shared)
    }
    
    func testInheritance() {
        XCTAssertEqual(InheritService.User.get.configuration, InheritService.configuration)
        XCTAssertEqual(InheritService.User.get.session, InheritService.session)
    }
    
    func testOverrideConfiguration() async throws {
        let expectedConfiguration = Request.Configuration(cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
        let override = Request(.get, parent: InheritService.User.self, configuration: expectedConfiguration)
        XCTAssertEqual(override.configuration, expectedConfiguration)
    }
}

extension URL {
    func appending(_ components: PathComponents) -> URL {
        var modified = self
        components.value.forEach { modified.appendPathComponent($0) }
        return modified
    }
}
