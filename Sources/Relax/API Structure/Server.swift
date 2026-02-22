//
//  Server.swift
//  Relax
//
//  Created by Thomas De Leon on 2/19/26.
//

import Foundation

public protocol Server {
    var url: URL { get }
}

public struct ServerDefinition: Server {
    public let url: URL
}
