//
//  ServerVariable.swift
//  Relax
//
//  Created by Thomas De Leon on 2/6/26.
//

import Foundation


@attached(peer)
public macro ServerVariable<T: CustomStringConvertible>(default: T) = #externalMacro(module: "RelaxMacros", type: "ServerVariableMacro")

@attached(peer)
public macro ServerVariable() = #externalMacro(module: "RelaxMacros", type: "ServerVariableMacro")
