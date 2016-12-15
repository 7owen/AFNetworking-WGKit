 //
//  WGURLRequestContext.swift
//  Sample
//
//  Created by 7owen on 2016/12/14.
//  Copyright © 2016年 7owen. All rights reserved.
//

import Foundation
import AFNetworking
 
public let kFileInfoDataKey = "kFileInfoDataKey"
public let kFileInfoNameKey = "kFileInfoNameKey"
public let kFileInfoFileNameKey = "kFileInfoFileNameKey"
public let kFileInfoMimeTypeKey = "kFileInfoMimeTypeKey"
 
public struct WGURLRequestContext {
    public var serverInfo: WGServerInfo
    public var path: String?
    public var user: String?
    public var password: String?
    public var method: String
    public var parameters: [String:String]?
    public var customHeader: [String:String]?
    public var customBody: Data?
    public var fileInfo: [String:AnyObject]?
    public var connectIPAddress: String?
}
 
public extension WGURLRequestContext {
    
    public init(serverInfo: WGServerInfo, path: String? = nil, user: String? = nil, password: String? = nil, method: String, parameters: [String:String]? = nil, customHeader: [String:String]? = nil, customBody: Data? = nil) {
        self.serverInfo = serverInfo
        self.path = path
        self.user = user
        self.password = password
        self.method = method
        self.parameters = parameters
        self.customHeader = customHeader
        self.customBody = customBody
    }
    
    public init?(url: String) {
        guard let aUrl = URL(string: url) else {
            return nil
        }
        
        let serverInfo = WGServerInfo(serverName:"OtherServer", scheme:aUrl.scheme, host:aUrl.host, port:aUrl.port, basePath:"")
        self.serverInfo = serverInfo
        self.user = aUrl.user
        self.password = aUrl.password
        self.method = "GET"
        let baseURL = generateHost(allowCustomIP: false)
        let absoluteURL = aUrl.absoluteString
        self.path = absoluteURL.replacingOccurrences(of: baseURL, with: "")
        if self.path?.lengthOfBytes(using: .utf8) == absoluteURL.lengthOfBytes(using: .utf8) {
            return nil
        }
    }
    
    public func generateURLRequest() -> URLRequest {
        return generateURLRequest(allowCustomIP: true)
    }
    
    public func generateURL() -> URL? {
        return generateURLRequest(allowCustomIP: false).url
    }
    
    private func generateURLRequest(allowCustomIP: Bool) -> URLRequest {
        let url = generateURLString(allowCustomIP: allowCustomIP)
        let requestSerializer = AFHTTPRequestSerializer()
        let request: NSMutableURLRequest!
        var error: NSError?
        if method != "GET" && method != "HEAD" && fileInfo != nil {
            request = requestSerializer.multipartFormRequest(withMethod: method, urlString: url, parameters: parameters, constructingBodyWith: { (formData) in
                if let fileInfo = self.fileInfo {
                    formData.appendPart(withFileData: fileInfo[kFileInfoDataKey] as! Data, name: fileInfo[kFileInfoNameKey] as! String, fileName: fileInfo[kFileInfoFileNameKey] as! String, mimeType: fileInfo[kFileInfoMimeTypeKey] as! String)
                }
            }, error: &error)
        } else {
            request = requestSerializer.request(withMethod: method, urlString: url, parameters: parameters, error: &error)
        }
        if let customBody = self.customBody {
            request.httpBody = customBody
        }
        if let customHeader = self.customHeader {
            customHeader.forEach({ (key,value) in
                request.setValue(value, forHTTPHeaderField: key)
            })
        }
        if allowCustomIP && connectIPAddress != nil, let host = serverInfo.host {
            request.addValue(host, forHTTPHeaderField: "Host")
        }
        if let error = error {
            print("Create HTTP Reuqest failed. error:\(error)")
        }
        return request as URLRequest
    }
    
    private func generateURLString(allowCustomIP: Bool) -> String {
        let url = self .generateHost(allowCustomIP: allowCustomIP)
        if let path = self.path {
            return url.appending(path)
        } else {
            return url
        }
    }
    
    private func generateHost(allowCustomIP: Bool) -> String {
        var url = ""
        if let scheme = serverInfo.scheme {
            url.append(scheme)
            url.append("://")
        }
        if let user = self.user {
            url.append(user)
            if let password = self.password {
                url.append(":")
                url.append(password)
                url.append("@")
            }
        }
        if let connectIPAddress = self.connectIPAddress, allowCustomIP {
            url.append(connectIPAddress)
        } else if let host = serverInfo.host {
            url.append(host)
        }
        if let port = serverInfo.port {
            url.append(":")
            url.append(String(port))
        }
        url.append(serverInfo.basePath)
        return url
    }
}
