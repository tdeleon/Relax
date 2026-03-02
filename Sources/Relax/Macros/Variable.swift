//
//  Variable.swift
//  Relax
//
//  Created by Thomas De Leon on 2/25/26.
//

import Foundation

@freestanding(expression)
public macro Variable<T: CustomStringConvertible>(
    _ name: StaticString,
    ofType type: T.Type,
    defaultValue: T? = nil,
    description: StaticString? = nil
) -> ServerDescription.Variable = #externalMacro(module: "RelaxMacros", type: "VariableMacro")


@freestanding(expression)
public macro Variable<T: RawRepresentable>(
    _ name: StaticString,
    ofType type: T.Type,
    defaultValue: T? = nil,
    description: StaticString? = nil
) -> ServerDescription.Variable = #externalMacro(module: "RelaxMacros", type: "VariableMacro") where T.RawValue: CustomStringConvertible
