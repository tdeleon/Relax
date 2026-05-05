//
//  OperationDecl.swift
//  Relax
//
//  Created by Thomas De Leon on 5/1/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

internal struct OperationDecl {
    let method: String
    let id: String
    let summary: String?
    let description: String?
    let parameters: [ParameterDecl]
    let repsonses: [ResponseDecl]
    
    private var functionName: String {
        (method+id.capitalized).camelCased()
    }
    
    private var parametersString: String {
        parameters.map {
            "\($0.name): \($0.type)\($0.required ? "?" : "")"
        }.joined(separator: ", ")
    }
    
    func generateDecl() throws -> FunctionDeclSyntax {
        try FunctionDeclSyntax(
            """
            \(raw: docComment ?? "")
            public func \(raw: functionName)(\(raw: parametersString)) -> {
                
            }
            """
        )
    }
}

extension OperationDecl: DocCommentRepresentable {
    var docComment: String? {
        var comment = ""
        if let summary {
            comment = "/// \(summary)"
            if let description {
                comment += "\n///\n"
                comment += description.commentFormatted()
            }
        } else if let description {
            comment = description.commentFormatted()
        }
        
        let parameterDescriptions = parameters.compactMap(\.docComment).joined(separator: "\n")
        
        if !parameterDescriptions.isEmpty {
            comment += "\n/// - Parameters:\n\(parameterDescriptions)"
        }
        return comment
    }
}

internal struct ResponseDecl {
    let summary: String?
    let description: String?
    let httpStatus: Int
    let content: [String: String]
    
    func decl(functionName: String, parameters: [ParameterDecl]) throws -> FunctionDeclSyntax {
        try FunctionDeclSyntax (
            """
            public func \(raw: functionName)() ->
            """
        )
    }
    
    func decl(contentType: String, payload: String, functionName: String, parameters: [ParameterDecl]) throws -> FunctionDeclSyntax {
        try FunctionDeclSyntax(
            """
            public func \(raw: functionName)() -> {
            }
            """
        )
    }
    
    func request(method: String, server: ServerDecl, parameters: [ParameterDecl]) throws -> VariableDeclSyntax {
        try VariableDeclSyntax(
            """
            
            """
        )
    }
}

internal struct ParameterDecl: ParameterFormattable {
    let name: String
    let type: String
    let required: Bool
    let description: String?
}

protocol DocCommentRepresentable {
    var docComment: String? { get }
}

protocol ParameterFormattable: DocCommentRepresentable {
    var name: String { get }
    var description: String? { get }
}

extension ParameterFormattable {
    var docComment: String? {
        guard let description else { return nil }
        return "///   - \(name): \(description)"
    }
}

