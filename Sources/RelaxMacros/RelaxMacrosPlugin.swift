//
//  RelaxMacrosPlugin.swift
//  
//
//  Created by Thomas De Leon on 12/27/23.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

#if canImport(XCTest) && os(Windows) // temporarily disable when running tests on windows https://github.com/apple/swift/issues/69302
#else
@main
struct RelaxMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        APIServiceMacro.self
    ]
}
#endif
