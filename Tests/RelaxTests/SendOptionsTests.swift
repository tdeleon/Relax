//
//  SendOptionsTests.swift
//  Relax
//
//  Created by Thomas De Leon on 5/14/26.
//

import Foundation
import Testing
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@testable import Relax

struct SendOptionsTests {

    @Test func `Send Options should be applied to a URLRequest`() async throws {
        let request = Request(.get, url: try #require(URL(string: "https://example.com/")))
        
        let options: SendOptions = {
            #if canImport(FoundationNetworking)
            SendOptions(
                cachePolicy: .returnCacheDataDontLoad,
                timeoutInterval: 5,
                httpShouldHandleCookies: false,
                allowsCellularAccess: false,
                networkServiceType: .video
            )
            #else
            SendOptions(
                cachePolicy: .returnCacheDataDontLoad,
                timeoutInterval: 5,
                httpShouldHandleCookies: false,
                allowsCellularAccess: false,
                networkServiceType: .video,
                allowsConstrainedNetworkAccess: false,
                allowsExpensiveNetworkAccess: false
            )
            #endif
        }()
        
        let modified = try request.urlRequest(applying: options)
        modified.verify(options: options)
    }
}

extension URLRequest {
    func verify(options: SendOptions) {
        if options.cachePolicy != nil {
            #expect(cachePolicy == options.cachePolicy)
        }
        if options.timeoutInterval != nil {
            #expect(timeoutInterval == options.timeoutInterval)
        }
        if options.httpShouldHandleCookies != nil {
            #expect(httpShouldHandleCookies == options.httpShouldHandleCookies)
        }
        if options.allowsCellularAccess != nil {
            #expect(allowsCellularAccess == options.allowsCellularAccess)
        }
        if options.networkServiceType != nil {
            #expect(networkServiceType == options.networkServiceType)
        }
        #if !canImport(FoundationNetworking)
        if options.allowsConstrainedNetworkAccess != nil {
            #expect(allowsConstrainedNetworkAccess == options.allowsConstrainedNetworkAccess)
        }
        if options.allowsExpensiveNetworkAccess != nil {
            #expect(allowsExpensiveNetworkAccess == options.allowsExpensiveNetworkAccess)
        }
        #endif
    }
}
