//
//  BodyTests.swift
//  
//
//  Created by Thomas De Leon on 1/20/23.
//

import XCTest
@testable import Relax

final class BodyTests: XCTestCase {

    let stringData1 = "Test".data(using: .utf8)
    let stringData2 = "Test2".data(using: .utf8)
    
    struct Test: Codable, Hashable {
        let name: String
    }
    
    let model = Test(name: "abc")
    
    func testInit() {
        let body = Body(data: stringData1)
        
        XCTAssertEqual(body._value, stringData1)
    }
    
    func testInitModel() throws {
        let encoder = JSONEncoder()
        
        let body = Body(model, encoder: encoder)
        let bodyData = try XCTUnwrap(body._value)
        XCTAssertEqual(try? JSONDecoder().decode(Test.self, from: bodyData), model)
    }
    
    func testInitDictionary() throws {
        let dictionary = ["key": "value"]
        let body = Body(dictionary)
        XCTAssertEqual(body._value, try JSONSerialization.data(withJSONObject: dictionary))
    }
    
    func testAppend() throws {
        let body1 = Body { stringData1 }
        let body2 = Body { stringData2 }
        
        XCTAssertEqual(body1 + body2, Body(data: stringData1! + stringData2!))
        
        let bodyNil = Body {}
        
        XCTAssertEqual(body1 + bodyNil, Body(data: stringData1!))
        XCTAssertEqual(bodyNil + body2, Body(data: stringData2!))
        XCTAssertEqual(bodyNil + bodyNil, Body(data: nil))
        
        let bodyAppended = Body {
            Body(data: stringData1)
            Body(data: stringData2)
        }
        XCTAssertEqual(bodyAppended._value, stringData1! + stringData2!)
    }
    
    func testBuildEmpty() {
        XCTAssertEqual(Body {}, Body(data: nil))
    }
    
    func testBuild() throws {
        let body1 = Body(data: stringData1)
        
        XCTAssertEqual(Body { body1 }._value, body1._value)
        
        let nonOptionalData = try XCTUnwrap(stringData2)
        let body2 = Body {
            nonOptionalData
        }
        XCTAssertEqual(body2._value, nonOptionalData)
        
        let dictionary = ["key": "value"]
        let body3 = Body {
            dictionary
        }
        XCTAssertEqual(body3._value, try JSONSerialization.data(withJSONObject: dictionary))
    }
    
    func testBuildOptional() {
        @Body.Builder
        func body(include: Bool) -> Body {
            if include {
                stringData1
            }
        }
        XCTAssertEqual(body(include: true), Body(data: stringData1))
        XCTAssertEqual(body(include: false), Body(data: nil))
    }
    
    func testBuildEither() {
        @Body.Builder
        func body(include: Bool) -> Body {
            if include {
                stringData1
            } else {
                stringData2
            }
        }
        
        XCTAssertEqual(body(include: true), Body(data: stringData1))
        XCTAssertEqual(body(include: false), Body(data: stringData2))
    }
    
    func testBuildArray() {
        let data = [stringData1, stringData2]
        
        @Body.Builder
        var body: Body {
            for item in data {
                item
            }
        }
        XCTAssertEqual(body, Body(data: data.compactMap { $0 }.reduce(Data(), +)))
    }
    
    func testBuildCodable() throws {
        @Body.Builder
        var body: Body {
            model
        }
        XCTAssertEqual(body, Body(model))
    }
    
    func testBuildDictionary() throws {
        let content = ["name": "value"]
        @Body.Builder
        var body: Body {
            content
        }
        XCTAssertEqual(body, Body(content))
    }
    
    func testBuildHeterogenousDictionary() throws {

        let content: [String: Any] = ["name": "value", "status": false]
        @Body.Builder
        var body: Body {
            content
        }
        #if os(Windows) && swift(>=5.7) && swift(<5.9)
        throw XCTSkip("Comparison does not work correctly on Windows with Swift 5.8")
        #else
        XCTAssertEqual(body, Body(content))
        #endif
    }
    
    func testBuildLimitedAvailability() {
        @Body.Builder
        var body: Body {
            if #available(*) {
                model
            }
        }
        XCTAssertEqual(body, Body(model))
    }
}
