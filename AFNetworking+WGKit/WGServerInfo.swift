//
//  WGServerInfo.swift
//  Sample
//
//  Created by 7owen on 2016/12/14.
//  Copyright © 2016年 7owen. All rights reserved.
//

import Foundation

public struct WGServerInfo {
    public var serverName: String
    public var scheme: String?
    public var host: String?
    public var port: Int?
    public var basePath: String
}

public extension WGServerInfo {
    public init(serverName: String, scheme: String, host: String, port: Int, basePath: String) {
        self.serverName = serverName
        self.scheme = scheme
        self.host = host
        self.port = port
        self.basePath = basePath
    }
    
    public init?(_ serverName: String, url: String) {
        if let aUrl = URL(string: url) {
            self.init(serverName:serverName, scheme:aUrl.scheme, host:aUrl.host, port:aUrl.port, basePath:aUrl.path)
        } else {
            return nil
        }
    }
    
    public func generateURL() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = basePath
        return components.url
    }
}
