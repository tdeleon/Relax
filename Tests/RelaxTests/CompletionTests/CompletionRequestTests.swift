//
//  CompletionRequestTests.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

final class CompletionRequestTests: XCTestCase {
    var session: URLSession!
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLMock.self]
        session = URLSession(configuration: configuration)
    }
    
    override func tearDown() {
        session = nil
    }
    
    private func makeSuccess(request: Request) {
        let expectation = self.expectation(description: "Expect")
        URLMock.response = .mock()
        
        request.send(session: session) { result in
            switch result {
            case .failure(let error):
                XCTFail("Request failed with error - \(error)")
            case .success(let received):
                XCTAssertEqual(request.urlRequest, received.request.urlRequest)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    
    func testGet() throws {
        makeSuccess(request: ExampleService.get)
    }
    
    func testPost() throws {
        makeSuccess(request: ExampleService.BasicRequests.get)
    }
    
    func testPatch() throws {
        makeSuccess(request: ExampleService.BasicRequests.patch)
    }
    
    func testPut() throws {
        makeSuccess(request: ExampleService.BasicRequests.put)
    }
    
    func testDelete() throws {
        makeSuccess(request: ExampleService.BasicRequests.delete)
    }
    
    func testComplexRequest() throws {
        makeSuccess(request: ExampleService.ComplexRequests.complex)
    }
    
    func testOverrideDecoderOnSend() throws {
        let success = self.expectation(description: "success")
        let fail = self.expectation(description: "fail")
        let model = InheritService.User.Response(date: .now)
        
        let session = URLMock.session(.mock(model, encoder: InheritService.iso8601Encoder))
        
        InheritService.User.get.send(session: session) { (result: Result<InheritService.User.Response, RequestError>) in
            switch result {
            case .success:
                success.fulfill()
            case .failure:
                XCTFail("Failed")
            }
        }
        
        InheritService.User.get.send(decoder: JSONDecoder(), session: session) { (result: Result<InheritService.User.Response, RequestError>) in
            switch result {
            case .success:
                XCTFail("Should fail")
            case .failure:
                fail.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOverrideSession() throws {
        let expectation = self.expectation(description: "Mock received")
        let expectedSession = URLMock.session(.mock { _ in
            expectation.fulfill()
        })
        
        let override = Request(.get, parent: InheritService.User.self, session: expectedSession)
        override.send(session: expectedSession) { _ in
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testOverrideSessionOnSend() throws {
        let expectation = self.expectation(description: "Mock received")
        let expectedSession = URLMock.session(.mock { _ in
            expectation.fulfill()
        })
        
        InheritService.User.get.send(session: expectedSession) { _ in
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testGetPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.get)
        }
    }
    
    func testPostPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.BasicRequests.post)
        }
    }
    
    func testPatchPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.BasicRequests.patch)
        }
    }
    
    func testPutPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.BasicRequests.put)
        }
    }
    
    func testDeletePerformance() throws {
        measure {
            makeSuccess(request: ExampleService.BasicRequests.delete)
        }
    }
    
    func testComplexRequestPerformance() throws {
        measure {
            makeSuccess(request: ExampleService.ComplexRequests.complex)
        }
    }
}
