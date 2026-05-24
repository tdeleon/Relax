//
//  BodyParameter.swift
//  Relax
//
//  Created by Thomas De Leon on 5/21/26.
//

import Foundation
import HTTPTypes

/// Defines a parameter that is sent as the body of a request
public struct BodyParameter: Sendable {
    internal let contentType: HTTPField.MediaType
    internal let payload: Payload
    internal let required: Bool
    internal let name: String
    internal let summary: String?
    
    internal enum Payload: @unchecked Sendable {
        case bytes
        case json(_ type: any Encodable.Type)
        case jsonDictionary
        case text(_ encoding: String.Encoding = .utf8)
    }
    
    /// Defines a request body parameter with an Encodable type
    /// - Parameters:
    ///   - type: The JSON encodable type
    ///   - name: The parameter name
    ///   - required: Whether the parameter is required
    ///   - summary: A summary of the parameter
    /// - Returns: A body parameter of an encodable type
    public static func json<T: Encodable>(
        _ type: T.Type,
        name: String,
        required: Bool = true,
        summary: String? = nil
    ) -> BodyParameter {
        self.init(
            contentType: .applicationJSON,
            payload: .json(type),
            required: required,
            name: name,
            summary: summary
        )
    }
    
    /// Defines a request body parameter with a JSON Dictionary
    /// - Parameters:
    ///   - name: The parameter name
    ///   - required: Whether the parameter is required
    ///   - summary: A summary of the parameter
    /// - Returns: A body parameter of a dictionary type (`[String: Any]`)
    public static func jsonDictionary(
        name: String,
        required: Bool = true,
        summary: String? = nil
    ) -> BodyParameter {
        self.init(
            contentType: .applicationJSON,
            payload: .jsonDictionary,
            required: required,
            name: name,
            summary: summary
        )
    }
    
    /// Defines a request body parameter with a String
    /// - Parameters:
    ///   - name: The parameter name
    ///   - encoding: The encoding to use; defaults to `.utf8`
    ///   - contentType: The content type; defaults to `.textPlain`
    ///   - required: Whether the parameter is required
    ///   - summary: A summary of the parameter
    /// - Returns: A body parameter of a String type
    public static func string(
        name: String,
        encoding: String.Encoding = .utf8,
        contentType: HTTPField.MediaType = .textPlain,
        required: Bool = true,
        summary: String? = nil
    ) -> BodyParameter {
        self.init(
            contentType: contentType,
            payload: .text(encoding),
            required: required,
            name: name,
            summary: summary
        )
    }
    
    /// Defines a request body parameter with Data
    /// - Parameters:
    ///   - name: The parameter name
    ///   - contentType: The content type; defaults to `.applicationOctetStream`
    ///   - required: Whether the parameter is required
    ///   - summary: A summary of the parameter
    /// - Returns: A body parameter of Data type
    public static func data(
        name: String,
        contentType: HTTPField.MediaType = .applicationOctetStream,
        required: Bool = true,
        summary: String? = nil
    ) -> BodyParameter {
        self.init(
            contentType: contentType,
            payload: .bytes,
            required: required,
            name: name,
            summary: summary
        )
    }
}
