//
//  Service.swift
//  
//
//  Created by Thomas De Leon on 1/26/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A type that defines a REST API service
///
/// A ``Service`` defines a REST API at the root level, and all ``Request``s and ``Endpoint``s which share a common base URL belong to the service.
/// You define common properties here which will be used by all requests that belong to the service.
@available(*, deprecated, renamed: "RestAPI", message: "Use the @RestAPI macro instead")
public typealias Service = APIComponent
