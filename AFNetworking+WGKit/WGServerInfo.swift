//
//  WGServerInfo.swift
//  Sample
//
//  Created by 7owen on 2016/12/14.
//  Copyright © 2016年 7owen. All rights reserved.
//

import Foundation

struct WGServerInfo {
    var serverName: String
    var scheme: String?
    var host: String?
    var port: Int?
    var basePath: String
}

extension WGServerInfo {
    init?(_ serverName: String, url: String) {
        if let aUrl = URL(string: url) {
            self.init(serverName:serverName, scheme:aUrl.scheme, host:aUrl.host, port:aUrl.port, basePath:aUrl.path)
        } else {
            return nil
        }
    }
    
    func generateURL() -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = basePath
        return components.url
    }
}
