//
//  BodyTests.swift
//  
//
//  Created by Thomas De Leon on 1/20/23.
//

import Foundation
import Testing

@testable import Relax

@Suite("Request Body Tests")
struct BodyTests {

    let stringData1 = "Test".data(using: .utf8)
    let stringData2 = "Test2".data(using: .utf8)
    
    struct Test: Codable, Hashable {
        let name: String
    }
    
    let model = Test(name: "abc")
    
    @Test("Init with Data value")
    func testInit() {
        let body = Body(value: stringData1)
        #expect(body.value == stringData1)
    }
    
    @Test("Init with Codable Model")
    func testInitModel() throws {
        let encoder = JSONEncoder()
        
        let body = Body(model, encoder: encoder)
        
        let bodyData = try #require(body.value)
        #expect((try? JSONDecoder().decode(Test.self, from: bodyData)) == model)
    }
    
    @Test("Init with Dictionary")
    func testInitDictionary() throws {
        let dictionary = ["key": "value"]
        let body = Body(dictionary)
        #expect(try JSONSerialization.data(withJSONObject: dictionary) == body.value)
    }
    
    @Test("Multiple Data values should be appended")
    func testAppend() throws {
        let body1 = Body { stringData1 }
        let body2 = Body { stringData2 }
        
        let combined = stringData1! + stringData2!
        
        #expect((body1 + body2) == Body(value: combined))
        
        let bodyNil = Body {}
        
        #expect((body1 + bodyNil) == Body(value: stringData1))
        #expect((bodyNil + body2) == Body(value: stringData2))
        #expect((bodyNil + bodyNil) == Body(value: nil))
        
        let bodyAppended = Body {
            Body(value: stringData1)
            Body(value: stringData2)
        }
        #expect(bodyAppended.value == combined)
    }
    
    @Test("Empty body should have a nil value")
    func testBuildEmpty() {
        #expect(Body {} == Body(value: nil))
    }
    
    @Test("Builder with value")
    func testBuild() throws {
        let body1 = Body(value: stringData1)
        
        #expect(Body { body1 }.value == body1.value)
        
        let nonOptionalData = try #require(stringData2)
        let body2 = Body {
            nonOptionalData
        }
        #expect(body2.value == nonOptionalData)
        
        let dictionary = ["key": "value"]
        let body3 = Body {
            dictionary
        }
        #expect(try JSONSerialization.data(withJSONObject: dictionary) == body3.value)
    }
    
    @Test("Builder with optional value")
    func testBuildOptional() {
        @Body.Builder
        func body(include: Bool) -> Body {
            if include {
                stringData1
            }
        }
        #expect(body(include: true) == Body(value: stringData1))
        #expect(body(include: false) == Body(value: nil))
    }
    
    @Test("Builder with if-else")
    func testBuildEither() {
        @Body.Builder
        func body(include: Bool) -> Body {
            if include {
                stringData1
            } else {
                stringData2
            }
        }
        
        #expect(body(include: true) == Body(value: stringData1))
        #expect(body(include: false) == Body(value: stringData2))
    }
    
    @Test("Builder with array")
    func testBuildArray() {
        let data = [stringData1, stringData2]
        
        @Body.Builder
        var body: Body {
            for item in data {
                item
            }
        }
        
        #expect(Body(value: data.compactMap({ $0 }).reduce(Data(), +)) == body)
    }
    
    @Test("Builder with Codable")
    func testBuildCodable() throws {
        @Body.Builder
        var body: Body {
            model
        }
        
        #expect(Body(model) == body)
    }
    
    @Test("Builder with dictionary")
    func testBuildDictionary() throws {
        let content = ["name": "value"]
        @Body.Builder
        var body: Body {
            content
        }
        
        #expect(Body(content) == body)
    }
    
    @Test("Builder with heterogenous dictionary")
    func testBuildHeterogenousDictionary() throws {

        let content: [String: Any] = ["name": "value", "status": false]
        @Body.Builder
        var body: Body {
            content
        }
        #if os(Windows) && swift(>=5.7) && swift(<5.9)
        throw XCTSkip("Comparison does not work correctly on Windows with Swift 5.8")
        #else
        #expect(Body(content) == body)
        #endif
    }
    
    @Test("Builder with limited availability")
    func testBuildLimitedAvailability() {
        @Body.Builder
        var body: Body {
            if #available(*) {
                model
            }
        }
        
        #expect(Body(model) == body)
    }
}
