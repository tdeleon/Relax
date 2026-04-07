//
//  SecurityScheme.swift
//  Relax
//
//  Created by Thomas De Leon on 4/3/26.
//

import Foundation

/// Defines a security scheme that can be used by an ``Path/Operation``.
///
/// Use the ``SecurityScheme`` to define how security is applied on various `Operations`. Supported ``SecurityType`` schemes include:
///  - ``SecurityType/apiKey``
///  - ``SecurityType/http``
///  - ``SecurityType/mutualTLS``
///  - ``SecurityType/oauth2``
///  - ``SecurityType/openIDConnect``
///
///
///  Each ``SecurityType`` has specific configuration options available.
///
///  ```swift
///  // Bearer Scheme
///  let bearer = SecurityScheme.http(.bearer) {
///      "Authorization using a bearer token"
///  }
///
///  // API Key Scheme
///  let apiKey = SecurityScheme.apiKey("Api-Key", in: .header) {
///      "An API key located in the header"
///  }
///
///  // OAuth Scheme
///  let oauth = SecurityScheme.oauth2 {
///      OAuthFlow.authorizationCode(
///          authorizationURL: "https://example.com/authorization",
///          tokenURL: "https://example.com/token",
///          scopes: ["read":"data", "write":"data"]
///      )
///      OAuthFlow.password(tokenURL: "https://example.com/token", refreshURL: "https://example.com/refresh")
///  } description: {
///      "OAuth scheme with authorization code and password flows"
///  }
///  ```
public struct SecurityScheme: Hashable, Sendable {
    /// Type of ``SecurityScheme``
    public enum SecurityType: Hashable, Sendable {
        /// API key security scheme
        case apiKey
        /// HTTP auth security scheme
        case http
        /// Mutual TLS security scheme
        case mutualTLS
        /// OAuth2 security scheme
        case oauth2
        /// OpenID Connect security scheme
        case openIDConnect
    }
    
    /// The location for an API key
    public enum Location: Hashable, Sendable {
        /// Query parameter location
        case query
        /// Header location
        case header
        /// Cookie location
        case cookie
    }
    
    /// HTTP Authentication Schemes
    ///
    /// As specified by [IANA](https://www.iana.org/assignments/http-authschemes/http-authschemes.xhtml).
    public enum HTTPAuthenticationScheme: String, Hashable, Sendable {
        /// Basic authentication
        case basic = "Basic"
        /// Bearer authentication
        case bearer = "Bearer"
        /// Concealed authentication
        case concealed = "Concealed"
        /// Digest authentication
        case digest = "Digest"
        /// DPoP authentication
        case dpop = "DPoP"
        /// GNAP authentication
        case gnap = "GNAP"
        /// HOBA authentication
        case hoba = "HOBA"
        /// Mutual authentication
        case mutual = "Mutual"
        /// Negotiate authentication
        case negotiate = "Negotiate"
        /// OAuth authentication
        case oauth = "OAuth"
        /// PrivateToken authentication
        case privateToken = "PrivateToken"
        /// SCRAM-SHA-1 authentication
        case scramSHA1 = "SCRAM-SHA-1"
        /// SCRAM-SHA-256 authentication
        case scramSHA256 = "SCRAM-SHA-256"
        /// vapid authentication
        case vapid
    }
    
    /// The type of security scheme
    public let type: SecurityType
    /// An optional description of the scheme
    public let description: String?
    /// An optional name of the scheme
    public let name: String?
    /// The location of the scheme, when ``type`` is ``SecurityType/apiKey``.
    public let location: Location?
    /// The scheme, when ``type`` is ``SecurityType/http``.
    public let scheme: HTTPAuthenticationScheme?
    /// OAuth2 security flows, when ``type`` is ``SecurityType/oauth2``.
    public let flows: Set<OAuthFlow>
    /// A [well-known URL](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfig) to discover the
    /// OpenID-Connect-Discovery [provider metadata](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderMetadata),
    /// when ``type`` is ``SecurityType/openIDConnect``.
    public let openIDConnectURL: String?
    /// URL to the [OAuth2 authorization server metadata](https://www.rfc-editor.org/rfc/rfc8414), when ``type`` is
    /// ``SecurityType/openIDConnect``.
    public let oauth2MetadataURL: String?
    
    /// Specify API Key scheme
    /// - Parameters:
    ///   - name: The name of the header, query or cookie parameter to be used.
    ///   - location: The location of the API key.
    ///   - description: A description for security scheme.
    /// - Returns: An API Key scheme
    public static func apiKey(
        _ name: String,
        in location: Location,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Self {
        self.init(type: .apiKey, description: description(), location: location)
    }
    
    /// Specify HTTP scheme
    /// - Parameters:
    ///   - scheme: The HTTP Authentication scheme
    ///   - description: A description for the security scheme
    /// - Returns: An HTTP scheme
    public static func http(
        _ scheme: HTTPAuthenticationScheme,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Self {
        self.init(type: .http, scheme: scheme)
    }
    
    /// Specify Mutual TLS scheme
    /// - Parameter description: A description for the security scheme
    /// - Returns: A Mutual TLS scheme
    public static func mutualTLS(@DescriptionBuilder description: () -> String? = { nil }) -> Self {
        self.init(type: .mutualTLS, description: description())
    }
    
    /// Specify an OAuth2 scheme
    /// - Parameters:
    ///   - flows: OAuth2 flows to use
    ///   - description: A description for the security scheme
    /// - Returns: An OAuth2 scheme
    public static func oauth2(
        metadataURL: String? = nil,
        @OAuthFlow.Builder flows: () -> Set<OAuthFlow>,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Self {
        self.init(
            type: .oauth2,
            description: description(), flows: flows(), oauth2MetadataURL: metadataURL
        )
    }
    
    /// Specify an OpenID Connect scheme
    /// - Parameters:
    ///   - url: The OpenID Connect URL
    ///   - description: A description for the security scheme
    /// - Returns: An OpenID Connect scheme
    public static func openIDConnect(
        url: String,
        @DescriptionBuilder description: () -> String? = { nil }
    ) -> Self {
        self.init(type: .openIDConnect, description: description(), openIDConnectURL: url)
    }
    
    internal init(
        type: SecurityType,
        description: String? = nil,
        name: String? = nil,
        location: Location? = nil,
        scheme: HTTPAuthenticationScheme? = nil,
        bearerFormat: String? = nil,
        flows: Set<OAuthFlow> = [],
        openIDConnectURL: String? = nil,
        oauth2MetadataURL: String? = nil
    ) {
        self.type = type
        self.description = description
        self.name = name
        self.location = location
        self.scheme = scheme
        self.flows = flows
        self.openIDConnectURL = openIDConnectURL
        self.oauth2MetadataURL = oauth2MetadataURL
    }
}

/// Configuration details for a supported OAuth Flow
public enum OAuthFlow: Hashable, Sendable {
    @resultBuilder
    public enum Builder {
        public static func buildBlock() -> Set<OAuthFlow> {
            []
        }
        
        public static func buildPartialBlock(first: Set<OAuthFlow>) -> Set<OAuthFlow> {
            first
        }
        
        public static func buildPartialBlock(
            accumulated: Set<OAuthFlow>,
            next: Set<OAuthFlow>
        ) -> Set<OAuthFlow> {
            accumulated.union(next)
        }
        
        public static func buildExpression(_ expression: OAuthFlow) -> Set<OAuthFlow> {
            [expression]
        }
    }
    
    /// Implicit flow
    /// - Parameters:
    ///  - authorizationURL: The authorization URL to be used for this flow.
    ///  - refreshURL: The optional URL to be used for obtaining refresh tokens.
    ///  - scopes: The available scopes for the OAuth2 security scheme.
    case implicit(authorizationURL: String, refreshURL: String? = nil, scopes: [String: String] = [:])
    /// Password flow
    /// - Parameters:
    ///  - tokenURL: The token URL to be used for this flow.
    ///  - refreshURL: The optional URL to be used for obtaining refresh tokens.
    ///  - scopes: The available scopes for the OAuth2 security scheme.
    case password(tokenURL: String, refreshURL: String? = nil, scopes: [String: String] = [:])
    /// Client Credentials flow
    /// - Parameters:
    ///  - tokenURL: The token URL to be used for this flow.
    ///  - refreshURL: The optional URL to be used for obtaining refresh tokens.
    ///  - scopes: The available scopes for the OAuth2 security scheme.
    case clientCredentials(tokenURL: String, refreshURL: String? = nil, scopes: [String: String] = [:])
    /// Authorization Code flow
    /// - Parameters:
    ///  - authorizationURL: The authorization URL to be used for this flow.
    ///  - tokenURL: The token URL to be used for this flow.
    ///  - refreshURL: The optional URL to be used for obtaining refresh tokens.
    ///  - scopes: The available scopes for the OAuth2 security scheme.
    case authorizationCode(
        authorizationURL: String,
        tokenURL: String,
        refreshURL: String? = nil,
        scopes: [String: String] = [:]
    )
    /// Device Authorization flow
    /// - Parameters:
    ///  - deviceAuthorizationURL: The device authorization URL to be used for this flow. 
    ///  - tokenURL: The token URL to be used for this flow.
    ///  - refreshURL: The optional URL to be used for obtaining refresh tokens.
    ///  - scopes: The available scopes for the OAuth2 security scheme.
    case deviceAuthorization(
        deviceAuthorizationURL: String,
        tokenURL: String,
        refreshURL: String? = nil,
        scopes: [String: String] = [:]
    )
}
