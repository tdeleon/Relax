//
//  APIService.swift
//
//
//  Created by Thomas De Leon on 12/27/23.
//

#if swift(>=5.9)
import Foundation

@attached(extension, conformances: APIComponent, names: named(baseURL))
public macro APIService(_ baseURL: String) = #externalMacro(module: "RelaxMacros", type: "APIServiceMacro")
#endif
