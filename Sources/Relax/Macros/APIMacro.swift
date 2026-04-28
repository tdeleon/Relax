//
//  APIMacro.swift
//  Relax
//
//  Created by Thomas De Leon on 4/1/26.
//

import Foundation

@attached(extension, conformances: API, names: arbitrary)
public macro API() = #externalMacro(module: "RelaxMacros", type: "APIMacro")
