//
//  RequestTests.swift
//  
//
//  Created by Thomas De Leon on 1/18/23.
//

import XCTest
@testable import Relax

final class RequestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasic() throws {
        let method = Request.HTTPMethod.post
        let url = URL(string: "https://example.com/")!
        
        let request = Request(method, url: url)
        XCTAssertEqual(request.httpMethod, method)
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.headers, [:])
        XCTAssertEqual(request.queryItems, [])
        XCTAssertEqual(request.pathParameters, [])
        XCTAssertNil(request.body)
        XCTAssertEqual(request.configuration, .default)
    }

}
