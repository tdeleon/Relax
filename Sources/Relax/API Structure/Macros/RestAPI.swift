//
//  RestAPI.swift
//
//
//  Created by Thomas De Leon on 12/27/23.
//

import Foundation

@attached(extension, conformances: APIComponent, names: named(baseURL))
public macro APIService(_ baseURL: String) = #externalMacro(module: "RelaxMacros", type: "APIServiceMacro")
