//
//  Parameter.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

public struct Parameter: Sendable {
    public enum Location: Sendable {
        case path
        case query
        case header
        case cookie
    }
    
    public enum Style: Sendable {
        public enum Path {
            case simple
            case label
            case matrix
        }
        
        public enum Query: Sendable {
            case form
            case spaceDelimited
            case pipeDelimited
            case deepObject
        }
        
        public enum Cookie: Sendable {
            case cookie
            case form
        }
    }
    
    let name: String
    let location: Location
    let description: String?
    let required: Bool
    let type: Any.Type
    
    internal init(
        _ name: String,
        ofType type: Any.Type,
        in location: Location,
        description: String? = nil,
        required: Bool = false
    ) {
        self.name = name
        self.location = location
        self.description = description
        self.required = required
        self.type = type
    }
    
    public static func path<T: CustomStringConvertible>(
        _ name: String,
        ofType type: T.Type = String.self,
        style: Style.Path = .simple,
        description: String? = nil
    ) -> Parameter {
        self.init(name, ofType: type, in: .path, description: description, required: true)
    }
    
    public static func query<T: CustomStringConvertible>(
        _ name: String,
        ofType type: T.Type = String.self,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query<T: CustomStringConvertible>(
        _ name: String,
        ofType type: [T].Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query<T: RawRepresentable>(
        _ name: String,
        ofType type: T.Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter where T.RawValue == CustomStringConvertible {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query(
        _ name: String,
        ofType type: [String: any CustomStringConvertible].Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func query<T: Encodable>(
        _ name: String,
        ofObjectType type: T.Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required)
    }
    
    public static func header<T: LosslessStringConvertible>(
        _ name: String,
        valueType: T.Type = String.self,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType.self, in: .header, description: description, required: required)
    }
    
    public static func header<T: LosslessStringConvertible>(
        _ name: String,
        valueType: [T].Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType.self, in: .header, description: description, required: required)
    }
    
    public static func cookie<T: LosslessStringConvertible>(
        _ name: String,
        valueType: T.Type = String.self,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .cookie, description: description, required: required)
    }
    
    public static func cookie<T: LosslessStringConvertible>(
        _ name: String,
        valueType: [T].Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .cookie, description: description, required: required)
    }
    
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> [Parameter] {
            []
        }
        
        public static func buildPartialBlock(first: [Parameter]) -> [Parameter] {
            first
        }
        
        public static func buildPartialBlock(accumulated: [Parameter], next: [Parameter]) -> [Parameter] {
            accumulated + next
        }
        
        public static func buildExpression(_ expression: Parameter) -> [Parameter] {
            [expression]
        }
    }
}
