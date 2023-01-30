//
//  CombineCodableTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

#if canImport(Combine)
import XCTest
import Combine
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CombineCodableTests: XCTestCase {
    typealias User = ExampleService.Users.User
    var session: URLSession!
    var cancellable: AnyCancellable?
    
    let service = ExampleService.Users.self

    override func setUpWithError() throws {
        session = URLSession.sessionWithMock
    }

    override func tearDownWithError() throws {
        session = nil
        URLProtocolMock.mock = nil
    }

    func testGet() throws {
        let sampleModel = [User(name: "1"), User(name: "2")]
        URLProtocolMock.mock = URLProtocolMock.mockResponse(model: sampleModel)
        let expectation = self.expectation(description: "Expect")
        
        cancellable = service.getRequest
            .send(session: session)
            .sink(receiveCompletion: { completion in
                defer { expectation.fulfill() }
                switch completion {
                case .failure(let error):
                    XCTFail("Failed - \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { (response: [User]) in
                XCTAssertEqual(response, sampleModel)
            })
        waitForExpectations(timeout: 1)
    }

}
#endif
