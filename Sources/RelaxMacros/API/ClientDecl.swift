//
//  ClientDecl.swift
//  Relax
//
//  Created by Thomas De Leon on 4/30/26.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

extension APIMacro {
    internal static func generateClient(on type: String) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("extension \(raw: type)") {
            """
            /// A client to make requests to the \(raw: type) API
            public struct Client: Sendable {
                public var server: Server
                public var configuration: Request.Configuration
                public var decoder: JSONDecoder
                public var sender: any RequestSending
                
                /// Creates a client using the specified shared parameters.
                ///
                /// - Parameters:
                ///   - server: The server to make requests against
                ///   - configuration: The configuration for requests
                ///   - decoder: The decoder to use when decoding JSON
                ///   - sender: The transport sender to use for requests
                ///
                /// The properties on the Client are used for all requests
                public init(
                    server: Server = server
                    configuration: Request.Configuration = .default
                    decoder: JSONDecoder = JSONDecoder()
                    sender: any RequestSending = URLSessionSender()
                ) {
                    self.server = server
                    self.configuration = configuration
                    self.decoder = decoder
                    self.sender = sender
                }
            }
            """
        }
    }
    
    internal static func generateTagNamespaces(for tags: [ParsedTag], on type: String) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("extension \(raw: type)") {
            """
            
            """
        }
    }
}
