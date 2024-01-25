//
//  ConfigurationTests.swift
//
//
//  Created by Thomas De Leon on 1/25/24.
//

import Foundation
import XCTest
@testable import Relax

final class ConfigurationTests: XCTestCase {
    let testURL = URL(string: "https://example.com/")!
    private func check(_ request: Request, against expected: Request.Configuration) {
        XCTAssertEqual(request.configuration, expected)
        
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.allowsCellularAccess, expected.allowsCellularAccess)
        XCTAssertEqual(urlRequest.cachePolicy, expected.cachePolicy)
        XCTAssertEqual(urlRequest.httpShouldUsePipelining, expected.httpShouldUsePipelining)
        XCTAssertEqual(urlRequest.networkServiceType, expected.networkServiceType)
        XCTAssertEqual(urlRequest.timeoutInterval, expected.timeoutInterval)
        XCTAssertEqual(urlRequest.httpShouldHandleCookies, expected.httpShouldHandleCookies)
        
        #if !canImport(FoundationNetworking)
        XCTAssertEqual(urlRequest.allowsConstrainedNetworkAccess, expected.allowsConstrainedNetworkAccess)
        XCTAssertEqual(urlRequest.allowsExpensiveNetworkAccess, expected.allowsExpensiveNetworkAccess)
        #endif
    }
    
    func testDefaultConfiguration() throws {
        let request = Request(.get, url: testURL)
        check(request, against: .default)
    }
    
    func testConfiguration() throws {
        #if canImport(FoundationNetworking)
        let configuration = Request.Configuration(
            allowsCellularAccess: false,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            httpShouldUsePipelining: true,
            networkServiceType: .avStreaming,
            timeoutInterval: 1,
            httpShouldHandleCookies: false,
            parseHTTPStatusErrors: true,
            appendTraillingSlashToPath: true
        )
        #else
        let configuration = Request.Configuration(
            allowsCellularAccess: false,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            httpShouldUsePipelining: true,
            networkServiceType: .avStreaming,
            timeoutInterval: 1,
            httpShouldHandleCookies: false,
            allowsConstrainedNetworkAccess: false,
            allowsExpensiveNetworkAccess: false,
            parseHTTPStatusErrors: true,
            appendTraillingSlashToPath: true
        )
        #endif
        
        let request = Request(.get, url: testURL, configuration: configuration)
        check(request, against: configuration)
    }
}
