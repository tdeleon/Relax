//
//  ServiceTests.swift
//  
//
//  Created by Thomas De Leon on 1/25/23.
//

import XCTest
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
        enum Testing: Service {
            static let baseURL = URL(string: "https://example.com")!
        }
        
        XCTAssertEqual(Testing.allProperties, .empty)
        XCTAssertEqual(Testing.configuration, .default)
    }
}

extension URL {
    func appending(_ components: PathComponents) -> URL {
        var modified = self
        components.value.forEach { modified.appendPathComponent($0) }
        return modified
    }
}
