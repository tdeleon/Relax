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

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class CombineErrorTests: XCTestCase {
    var cancellable: AnyCancellable?
    
    var session: URLSession!
        
    override class func setUp() {
        
    }
    
    override func tearDown() {
        cancellable = nil
        session = nil
    }
    
    private func requestError(error: RequestError) throws {
        let expectation = self.expectation(description: "Expect")
        session = MockURLSession(requestError: error)
        cancellable = ExampleService().request(ExampleService.Get(), session: session)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let receivedError):
                    XCTAssertEqual(receivedError, error)
                    break
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { (received) in
                XCTFail("Expected to fail with an error")
            })
        
        waitForExpectations(timeout: 3)
    }
    
    func  testBasicRequest() throws {
        let expectation = self.expectation(description: "Expect")
        let status = 201
        let expectedRequest = URLRequest(request: ExampleService.Get(), baseURL: ExampleService().baseURL)
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
                XCTAssertEqual(received.request, expectedRequest)
            })
        
        waitForExpectations(timeout: 3)
    }
    
    func testBadRequestError() throws {
        try requestError(error: RequestError.badRequest(request: URLRequest(request: ExampleService.Get(), baseURL: ExampleService().baseURL)!))
    }
    
    func testUnauthorizedError() throws {
        try requestError(error: RequestError.unauthorized(request: ExampleService.Get().urlRequest))
    }
    
    func testNotFoundError() throws {
        try requestError(error: RequestError.notFound(request: ExampleService.Get().urlRequest))
    }
    
    func testServerError() throws {
        try requestError(error: RequestError.serverError(request: ExampleService.Get().urlRequest, status: 500))
    }
    
    func testOtherHTTPError() throws {
        try requestError(error: RequestError.otherHTTP(request: ExampleService.Get().urlRequest, status: 999))
    }
    
    func testURLError() throws {
        try requestError(error: RequestError.urlError(request: ExampleService.Get().urlRequest, error: URLError(.badURL)))
    }
    
    func testNoResponseError() throws {
        // always returns URL error with combine
//        try requestError(error: RequestError.noResponse(request: ExampleService.Get.urlRequest))
    }
    
    func testOtherError() throws {
        // always returns url error with combine
//        try requestError(error: RequestError.other(request: ExampleService.Get.urlRequest, message: "Other error occurred"))
    }
}
#endif
