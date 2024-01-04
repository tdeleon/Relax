//
//  APIEndpoint.swift
//  
//
//  Created by Thomas De Leon on 1/3/24.
//

#if swift(>=5.9)
import Foundation

@attached(extension, conformances: Endpoint, names: named(Parent), named(path))
public macro APIEndpoint<APIComponent>(_ path: String) = #externalMacro(module: "RelaxMacros", type: "APIEndpointMacro")
#endif
