//
//  CombineCodableTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

#if canImport(Combine)
import XCTest
import Combine
import URLMock
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class CombineCodableTests: XCTestCase {
    typealias User = ExampleService.Users.User
    var session: URLSession!
    var cancellables = Set<AnyCancellable>()
    
    let service = ExampleService.Users.self

    override func setUpWithError() throws {
        session = URLMock.session()
    }

    override func tearDownWithError() throws {
        session = nil
    }

    func testGet() throws {
        let sampleModel = [User(name: "1"), User(name: "2")]
        URLMock.response = .mock(sampleModel)
        let expectation = self.expectation(description: "Expect")
        
        service.getRequest
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
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
    }
    
    func testOverrideDecoderOnSend() throws {
        let success = self.expectation(description: "Success")
        let failure = self.expectation(description: "Failure")
        let model = InheritService.User.Response(date: Date())

        let session = URLMock.session(.mock(model, encoder: InheritService.iso8601Encoder))
        
        InheritService.User.get.send(session: session)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    XCTFail("Should succeed")
                }
            }, receiveValue: { (response: InheritService.User.Response) in
                success.fulfill()
            })
            .store(in: &cancellables)
        
        InheritService.User.get.send(decoder: JSONDecoder(), session: session)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    failure.fulfill()
                }
            }, receiveValue: { (response: InheritService.User.Response) in
                XCTFail()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
    }
}
#endif
