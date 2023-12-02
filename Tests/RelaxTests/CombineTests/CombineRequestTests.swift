//
//  CombineRequestTests.swift
//  
//
//  Created by Thomas De Leon on 5/21/20.
//

#if canImport(Combine)
import XCTest
import Combine
import URLMock
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineRequestTests: XCTestCase {
    var cancellable: AnyCancellable?
    
    var session: URLSession!
        
    override func setUp() {
        session = URLMock.session()
    }
    
    override func tearDown() {
        cancellable = nil
        session = nil
    }
    
    private func makeSuccess(request: Request) {
        let expectation = self.expectation(description: "Expect")
        URLMock.response = .mock()
        
        cancellable = request.send(session: session)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    XCTFail("Request failed with error - \(error)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { received in
                XCTAssertEqual(request.urlRequest, received.request.urlRequest)
            })
        
        waitForExpectations(timeout: 3)
    }
    
    func testGet() throws {
        makeSuccess(request: ExampleService.get)
    }
    
    func testPost() throws {
        makeSuccess(request: ExampleService.BasicRequests.post)
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
#endif
