//
//  ServiceTests.swift
//  
//
//  Created by Thomas De Leon on 1/25/23.
//

import XCTest
import URLMock
@testable import Relax

final class ServiceTests: XCTestCase {
    typealias Complex = ExampleService.ComplexRequests
    typealias SubComplex = ExampleService.ComplexRequests.SubComplex
    
    enum InheritService: Service {
        static let baseURL = URL(string: "https://example.com")!
        static var configuration: Request.Configuration = Request.Configuration(allowsCellularAccess: false)
        static let session: URLSession = URLSession(configuration: .ephemeral)
        
        enum User: Endpoint {
            static var path: String = "users"
            typealias Parent = InheritService
            
            static let get = Request(.get, parent: User.self)
        }
    }

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
    
    func testOverrideSession() async throws {
        let expectation = self.expectation(description: "Mock received")
        let expectedSession = URLMock.session(.mock { _ in
            expectation.fulfill()
        })
        
        let override = Request(.get, parent: InheritService.User.self, session: expectedSession)
        try await override.send()
        
        await fulfillment(of: [expectation])
    }
    
    func testOverrideSessionOnSend() async throws {
        let expectation = self.expectation(description: "Mock received")
        let expectedSession = URLMock.session(.mock { _ in
            expectation.fulfill()
        })
        try await InheritService.User.get.send(session: expectedSession)
        
        await fulfillment(of: [expectation])
    }
}

extension URL {
    func appending(_ components: PathComponents) -> URL {
        var modified = self
        components.value.forEach { modified.appendPathComponent($0) }
        return modified
    }
}
