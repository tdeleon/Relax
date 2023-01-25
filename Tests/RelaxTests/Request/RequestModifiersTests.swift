//
//  RequestModifiersTests.swift
//  
//
//  Created by Thomas De Leon on 1/24/23.
//

import XCTest
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import Relax

final class RequestModifiersTests: XCTestCase {
    
    let sampleURL = URL(string: "https://example.com/")!
    
    lazy var emptyRequest: Request = { Request(.get, url: sampleURL) }()

    func testSetting() {
        let request = Request(.get, url: sampleURL) {
            PathComponents { "path" }
        }
        
        let newComponents = PathComponents { "other" }
        
        XCTAssertEqual(request.setting(newComponents).pathComponents, newComponents.baseValue)
    }
    
    func testAdding() {
        let first = "first"
        let second = "second"
        let request = Request(.get, url: sampleURL) {
            PathComponents { first }
        }
        
        let newComponents = PathComponents { second }
        
        XCTAssertEqual(request.adding(newComponents).pathComponents, [first, second])
    }
    
    func testSettingConfiguration() {
        let request = Request(.get, url: sampleURL)
        XCTAssertEqual(request.configuration, .default)
        
        let newConfiguration = Request.Configuration(cachePolicy: .returnCacheDataDontLoad, allowsExpensiveNetworkAccess: false)
        
        XCTAssertEqual(request.setting(newConfiguration).configuration, newConfiguration)
    }
    
    func testSettingHeader() {
        let headerName = Header.Name("first")
        let firstHeader = Header(headerName, "value")
        let request = Request(.get, url: sampleURL) {
            Headers {
                firstHeader
            }
        }
        
        let headerValue = "value1"
        
        let expectedRequest = Request(.get, url: sampleURL) {
            Headers {
                [headerName.rawValue: headerValue]
            }
        }
        XCTAssertEqual(request.settingHeader(name: headerName.rawValue, value: headerValue), expectedRequest)
        XCTAssertEqual(request.settingHeader(name: headerName, value: headerValue), expectedRequest)
        XCTAssertEqual(request.settingHeader(Header(headerName, headerValue)), expectedRequest)
        XCTAssertEqual(request.settingHeader(name: headerName, value: nil), emptyRequest)
    }
    
    func testAddingHeader() {
        let headerName = Header.Name("value")
        let value1 = "value1"
        let value2 = "value2"
        let request = Request(.get, url: sampleURL) {
            Headers { [headerName.rawValue: value1] }
        }
        
        let expectedRequest = Request(.get, url: sampleURL) {
            Headers { [headerName.rawValue: "\(value1),\(value2)"]}
        }
        XCTAssertEqual(request.addingHeader(Header(headerName, value2)), expectedRequest)
        XCTAssertEqual(request.addingHeader(name: headerName.rawValue, value: value2), expectedRequest)
        XCTAssertEqual(request.addingHeader(name: headerName, value: value2), expectedRequest)
        XCTAssertEqual(request.removingHeader(headerName), emptyRequest)
        XCTAssertEqual(request.removingHeader(headerName.rawValue), emptyRequest)
    }

}
