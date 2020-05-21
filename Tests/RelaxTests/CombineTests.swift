//
//  CombineTests.swift
//  
//
//  Created by Thomas De Leon on 5/20/20.
//

#if os(macOS) || os(iOS) || os(tvOS)
import XCTest
import Combine
import MockURLSession
@testable import Relax

struct ExampleService: Service {
    let baseURL: URL = URL(string: "https://.com")!
    
    struct Get: ServiceRequest {
        let requestType: HTTPRequestMethod = .get
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineTests2: XCTestCase {
    var cancellable: AnyCancellable?
    func  testBasicRequest() throws {
        let expectation = self.expectation(description: "Expect")
        let status = 201
        let session = MockURLSession(data: nil, httpStatus: status, delay: 0)
        cancellable = ExampleService().request(ExampleService.Get(), session: session)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let error):
                    XCTFail("Request failed \(error)")
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { received in
                XCTAssertEqual(received.response.statusCode, status)
            })
        
        waitForExpectations(timeout: 3)
        
    }
}
#endif
