//
//  RelaxMacroDiagnostic.swift
//
//
//  Created by Thomas De Leon on 1/2/24.
//

import SwiftDiagnostics

enum RelaxMacroDiagnostic: String, DiagnosticMessage {
    case invalidBaseURL
    case invalidPath
    case missingParent
    
    var severity: DiagnosticSeverity { .error }
    
    var message: String {
        switch self {
        case .invalidBaseURL:
            "The base URL is invalid."
        case .invalidPath:
            "The path is invalid."
        case .missingParent:
            "The parent APIComponent must be specified as a generic argument."
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "RelaxMacros", id: rawValue)
    }
}

enum RelaxFixItMessage: String, FixItMessage {
    case missingParent
    var message: String {
        switch self {
        case .missingParent:
            "Add generic argument 'APIComponent'"
        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        MessageID(domain: "RelaxMacros", id: rawValue)
    }
    
    
}
