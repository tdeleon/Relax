//
//  Parameter.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

public struct Parameter: Sendable {
    /// Describes the location of a parameter
    public enum Location: Sendable {
        /// A parameter located in the path
        case path
        /// A parameter located in the query string
        case query
        /// A parameter located in the header
        case header
        /// A parameter located in the cookie
        case cookie
    }
    
    /// The style of how the parameter is sent in a request
    public enum Style: Sendable {
        /// Styles specific for path parameters
        case path(Style.Path)
        case query(Style.Query)
        case cookie(Style.Cookie)
        
        public enum Path: Sendable {
            case simple
            case label
            case matrix
        }
        
        /// Styles specific for query parameters
        public enum Query: Sendable {
            case form
            case spaceDelimited
            case pipeDelimited
            case deepObject
        }
        
        /// Styles specific for cookie parameters
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
    let style: Style?
    let explode: Bool?
    
    internal init(
        _ name: String,
        ofType type: Any.Type,
        in location: Location,
        description: String? = nil,
        required: Bool = false,
        style: Style? = nil,
        explode: Bool? = nil
    ) {
        self.name = name
        self.location = location
        self.description = description
        self.required = required
        self.type = type
        self.style = style
        self.explode = explode
    }
    
    //MARK: Path
    
    /// Describes a path parameter
    /// - Parameters:
    ///   - name: The parameter name
    ///   - type: The type of the parameter
    ///   - style: The style when the parameter is sent in a request
    ///   - description: A description of the parameter
    /// - Returns: A path parameter description
    public static func path<T: CustomStringConvertible>(
        _ name: String,
        ofType type: T.Type = String.self,
        style: Style.Path = .simple,
        description: String? = nil
    ) -> Parameter {
        self.init(name, ofType: type, in: .path, description: description, required: true, style: .path(style))
    }
    
    //MARK: Query
    
    /// Describes a query parameter of a `CustomStringConvertible` type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - type: The type of the parameter
    ///   - style: The style when the parameter is sent in a request
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A query parameter description
    public static func query<T: CustomStringConvertible>(
        _ name: String,
        ofType type: T.Type = String.self,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required, style: .query(style))
    }
    
    /// Describes a query parameter of an array of a `CustomStringConvertible` type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - type: The type of the parameter
    ///   - style: The style when the parameter is sent in a request
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A query parameter description
    public static func query<T: CustomStringConvertible>(
        _ name: String,
        ofType type: [T].Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required, style: .query(style))
    }
    
    /// Describes a query parameter of a `RawRepresentable` type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - type: The type of the parameter
    ///   - style: The style when the parameter is sent in a request
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A query parameter description
    public static func query<T: RawRepresentable>(
        _ name: String,
        ofType type: T.Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter where T.RawValue: CustomStringConvertible {
        self.init(name, ofType: type, in: .query, description: description, required: required, style: .query(style))
    }
    
    /// Describes a query parameter of a `RawRepresentable` type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - type: The type of the parameter
    ///   - style: The style when the parameter is sent in a request
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A query parameter description
    public static func query<T: RawRepresentable>(
        _ name: String,
        ofType type: [T].Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter where T.RawValue: CustomStringConvertible {
        self.init(name, ofType: type, in: .query, description: description, required: required, style: .query(style))
    }
    
    /// Describes a query parameter of a dictionary type`
    /// - Parameters:
    ///   - name: The parameter name
    ///   - type: The type of the parameter
    ///   - style: The style when the parameter is sent in a request
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A query parameter description
    public static func query<T: CustomStringConvertible>(
        _ name: String,
        ofType type: [String: T].Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required, style: .query(style))
    }
    
    /// Describes a query parameter of an encodable object type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - type: The type of the parameter
    ///   - style: The style when the parameter is sent in a request
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A query parameter description
    public static func query<T: Encodable>(
        _ name: String,
        ofObjectType type: T.Type,
        style: Style.Query = .form,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: type, in: .query, description: description, required: required, style: .query(style))
    }
    
    //MARK: Header
    
    /// Describes a header parameter of a `LosslessStringConvertible` type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - valueType: The type of the parameter
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A header parameter description
    public static func header<T: LosslessStringConvertible>(
        _ name: String,
        valueType: T.Type = String.self,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .header, description: description, required: required)
    }
    
    /// Describes a header parameter of an array value type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - valueType: The type of the parameter
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A header parameter description
    public static func header<T: LosslessStringConvertible>(
        _ name: String,
        valueType: [T].Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .header, description: description, required: required)
    }
    
    //MARK: Cookie
    
    /// Describes a cookie parameter of a value type
    /// - Parameters:
    ///   - name: The parameter name
    ///   - valueType: The type of the parameter
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A header parameter description
    public static func cookie<T: LosslessStringConvertible>(
        _ name: String,
        valueType: T.Type = String.self,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .cookie, description: description, required: required)
    }
    
    /// Describes a cookie parameter of a value type array
    /// - Parameters:
    ///   - name: The parameter name
    ///   - valueType: The type of the parameter
    ///   - description: A description of the parameter
    ///   - required: Whether the parameter is required
    /// - Returns: A header parameter description
    public static func cookie<T: LosslessStringConvertible>(
        _ name: String,
        valueType: [T].Type,
        description: String? = nil,
        required: Bool = false
    ) -> Parameter {
        self.init(name, ofType: valueType, in: .cookie, description: description, required: required)
    }
    
    //MARK: - Result Builder
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
