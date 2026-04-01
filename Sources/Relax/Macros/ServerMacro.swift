//
//  ServerMacro.swift
//  Relax
//
//  Created by Thomas De Leon on 2/18/26.
//

import Foundation

/// Converts a type into a Server definition
///
/// - Parameter urlTemplate: A template defining the base URL for the server. This can optionally contain variables inside `{}` which
///     are replaced with the values of their matching properties at runtime. Properties can be any type conforming to [`CustomStringConvertible`](https://developer.apple.com/documentation/Swift/CustomStringConvertible).
///
/// Conforms a type to the ``Server`` protocol to provide a customized server definition. Provide a `urlTemplate` with the base URL for the server to use,
/// optionally including variables. You then add matching properties of the same name as the template variables to the attached type, and the value will be replaced
/// at runtime.
///
/// In the below example, the values of the `domain` and `port` properties will be used to construct the ``Server/url`` property that the ``Server`` protocol provides"
/// ```
/// @Server("https://{domain}.example.com:{port}")
/// struct MyServer {
///   let domain: String = "prod"
///   let port: Int
/// }
/// ```
///
/// - Important: Template placeholder variables cannot have duplicates, and **must** have a matching non-optional property defined in the attached type.

//@attached(extension, conformances: Server, names: arbitrary)
//public macro Server(_ urlTemplate: StaticString) = #externalMacro(module: "RelaxMacros", type: "ServerMacro")

/// Generates a type defining a server with a static base URL
///
/// - Parameter name: The name of the server
/// - Parameter url: The base URL of the server
@freestanding(expression)
public macro Server(_ name: String, url: StaticString, description: String? = nil) = #externalMacro(module: "RelaxMacros", type: "ServerMacro")
