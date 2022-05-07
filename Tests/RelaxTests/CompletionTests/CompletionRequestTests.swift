//
//  CompletionRequestTests.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

#if !os(watchOS)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

final class CompletionRequestTests: XCTestCase {
    var session: URLSession!
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: configuration)
    }
    
    override func tearDown() {
        session = nil
        URLProtocolMock.mock = nil
    }
    
    private func makeSuccess<Request: ServiceRequest>(request: Request) {
        let expectation = self.expectation(description: "Expect")
        URLProtocolMock.mock = { request in
            let response = HTTPURLResponse(url: URL(string: "http://example.com/")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, nil, nil,0)
        }
        let service = ExampleService()
        service.request(request, session: session) { (result) in
            switch result {
            case .failure(let error):
                XCTFail("Request failed with error - \(error)")
            case .success(let received):
                service.checkSuccess(request: request, received: received.request)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    
    func testGet() throws {
        makeSuccess(request: ExampleService.Get())
    }
    
    func testPost() throws {
        makeSuccess(request: ExampleService.Post())
    }
    
    func testPatch() throws {
        makeSuccess(request: ExampleService.Patch())
    }
    
    func testPut() throws {
        makeSuccess(request: ExampleService.Put())
    }
    
    func testDelete() throws {
        makeSuccess(request: ExampleService.Delete())
    }
    
    func testComplexRequest() throws {
        makeSuccess(request: ExampleService.ExampleEndpoint.Complex())
    }
    
    func testNoContentType() throws {
        makeSuccess(request: ExampleService.NoContentType())
    }
    
    func testGetPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.Get())
        }
    }
    
    func testPostPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.Post())
        }
    }
    
    func testPatchPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.Patch())
        }
    }
    
    func testPutPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.Put())
        }
    }
    
    func testDeletePerformance() throws {
        measure {
            makeSuccess(request: ExampleService.Delete())
        }
    }
    
    func testComplexRequestPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.ExampleEndpoint.Complex())
        }
    }
    
    func testNoContentTypePerformance() throws {
        measure {
            makeSuccess(request: ExampleService.NoContentType())
        }
    }
}
#endif
