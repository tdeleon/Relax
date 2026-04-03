//
//  RelaxMacrosPlugin.swift
//  
//
//  Created by Thomas De Leon on 12/27/23.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct RelaxMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        APIMacro.self,
        APIServiceMacro.self,
        APIEndpointMacro.self,
        ServerVariableMacro.self,
        ServerMacro.self,
        VariableMacro.self
    ]
}
