//
//  AsyncCodableTests.swift
//
//
//  Created by Thomas De Leon on 11/11/21.
//

#if swift(>=5.5)
import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import URLMock
@testable import Relax

@available(iOS 13.0, macOS 10.15, tvOS 13.0, *)
final class AsyncCodableTests: XCTestCase {
    typealias Users = ExampleService.Users
    typealias User = Users.User
    var session: URLSession!
    
    override func setUpWithError() throws {
        ExampleService.session = URLMock.session()
    }
    
    let users = ExampleService.Users.self
    
    func testGet() async throws {
        let sampleModel = [User(name: "test1"), User(name: "test2")]
        URLMock.response = .mock(sampleModel)
        
        let users: [User] = try await Users.get()
        XCTAssertEqual(users, sampleModel)
    }
    
    func testGetOne() async throws {
        let sampleModel = User(name: "someone")
        URLMock.response = .mock(sampleModel)
        
        let user = try await Users.get(sampleModel.name)
        XCTAssertEqual(user, sampleModel)
    }
    
    func testAdd() async throws {
        let new = User(name: "someone")
        URLMock.response = .mock()
        
        try await Users.add(new)
    }
}
#endif
