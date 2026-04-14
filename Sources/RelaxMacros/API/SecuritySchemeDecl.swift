//
//  SecuritySchemeDecl.swift
//  Relax
//
//  Created by Thomas De Leon on 4/10/26.
//

import Foundation
import SwiftSyntax

internal struct SecuritySchemeDecl: Hashable {
    let type: String
    let description: String?
    let name: String?
    let location: String?
    let scheme: String?
    let flows: [OAuthFlowDecl]
    let openIDConnectURL: String?
    let oauth2MetadataURL: String?
    let expr: FunctionCallExprSyntax
    
    internal init(
        type: String,
        description: String? = nil,
        name: String? = nil,
        location: String? = nil,
        scheme: String? = nil,
        flows: [OAuthFlowDecl] = [],
        openIDConnectURL: String? = nil,
        oauth2MetadataURL: String? = nil,
        expr: FunctionCallExprSyntax
    ) {
        self.type = type
        self.description = description
        self.name = name
        self.location = location
        self.scheme = scheme
        self.flows = flows
        self.openIDConnectURL = openIDConnectURL
        self.oauth2MetadataURL = oauth2MetadataURL
        self.expr = expr
    }
    
    static func from(_ expr: FunctionCallExprSyntax) -> Self? {
        guard expr.baseName(matches: "SecurityScheme") else { return nil }
        
        switch "\(expr.calledExpression.trimmed)".trimmingPrefix("SecurityScheme.") {
        case "apiKey":
            return parseAPIKey(expr)
        case "http":
            return parseHTTP(expr)
        case "mutualTLS":
            return parseMutualTLS(expr)
        case "oauth2":
            return parseOAuth2(expr)
        case "openIDConnect":
            return parseOpenIDConnect(expr)
        default:
            return nil
        }
    }
    
    private static func parseAPIKey(_ expr: FunctionCallExprSyntax) -> Self? {
        guard let name = expr.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue,
              let location = expr.argument("in")?.expression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription
        else { return nil }
        
        let description = expr.parseDescription()
        
        return SecuritySchemeDecl(
            type: "apiKey",
            description: description,
            name: name,
            location: location,
            expr: expr
        )
    }
    
    private static func parseHTTP(_ expr: FunctionCallExprSyntax) -> Self? {
        let scheme = expr.arguments.first?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text
        let description = expr.parseDescription()
        
        return SecuritySchemeDecl(type: "http", description: description, scheme: scheme, expr: expr)
    }
    
    private static func parseMutualTLS(_ expr: FunctionCallExprSyntax) -> Self? {
        SecuritySchemeDecl(type: "mutualTLS", description: expr.parseDescription(), expr: expr)
    }
    
    private static func parseOAuth2(_ expr: FunctionCallExprSyntax) -> Self? {
        let url = expr.argument("metadataURL")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        
        let flows = expr.trailingClosure?.statements
            .compactMap { $0.item.as(FunctionCallExprSyntax.self) }
            .compactMap { OAuthFlowDecl.from($0) } ?? []
        
        let description = expr.parseDescription()
        
        return SecuritySchemeDecl(
            type: "oauth2",
            description: description,
            flows: flows,
            oauth2MetadataURL: url,
            expr: expr
        )
    }
    
    private static func parseOpenIDConnect(_ expr: FunctionCallExprSyntax) -> Self? {
        guard let url = expr.argument("url")?.expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        else { return nil }
        
        return SecuritySchemeDecl(
            type: "openIDConnect",
            description: expr.parseDescription(),
            openIDConnectURL: url,
            expr: expr
        )
    }
}

internal struct OAuthFlowDecl: Hashable {
    let type: String
    let refreshURL: String?
    let scopes: [String: String]
    let tokenURL: String?
    let authorizationURL: String?
    let deviceAuthorizationURL: String?
    
    static func from(_ expr: FunctionCallExprSyntax) -> Self? {
        guard let type = expr.calledExpression.as(MemberAccessExprSyntax.self)?.declName.trimmedDescription
        else { return nil }
        
        let refreshURL = expr.argument("refreshURL")?
            .expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        
        let tokenURL = expr.argument("tokenURL")?
            .expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        
        let authorizationURL = expr.argument("authorizationURL")?
            .expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        
        let deviceAuthorizationURL = expr.argument("deviceAuthorizationURL")?
            .expression.as(StringLiteralExprSyntax.self)?.representedLiteralValue
        
        let scopes = expr.argument("scopes")?
            .expression.as(DictionaryExprSyntax.self)?
            .content.as(DictionaryElementListSyntax.self)?
            .compactMap { ("\($0.key)", "\($0.value)") }
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
        
        switch type {
        case "implicit":
            guard authorizationURL != nil else { return nil }
        case "password", "clientCredentials":
            guard tokenURL != nil else { return nil }
        case "authorizationURL":
            guard authorizationURL != nil, tokenURL != nil else { return nil }
        case "deviceAuthorization":
            guard deviceAuthorizationURL != nil, tokenURL != nil else { return nil }
        default:
            return nil
        }
        
        return OAuthFlowDecl(
            type: type,
            refreshURL: refreshURL,
            scopes: scopes ?? [:],
            tokenURL: tokenURL,
            authorizationURL: authorizationURL,
            deviceAuthorizationURL: deviceAuthorizationURL
        )
    }
}
