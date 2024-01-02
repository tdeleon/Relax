//
//  RelaxMacroDiagnostic.swift
//
//
//  Created by Thomas De Leon on 1/2/24.
//

import SwiftDiagnostics

enum RelaxMacroDiagnostic: String, DiagnosticMessage {
    case invalidBaseURL
    
    var severity: DiagnosticSeverity { .error }
    
    var message: String {
        switch self {
        case .invalidBaseURL:
            "The base URL is invalid."
        }
    }
    
    var diagnosticID: MessageID {
        MessageID(domain: "RelaxMacros", id: rawValue)
    }
}
