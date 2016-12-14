 //
//  WGURLRequestContext.swift
//  Sample
//
//  Created by 7owen on 2016/12/14.
//  Copyright © 2016年 7owen. All rights reserved.
//

import Foundation
import AFNetworking
 
let kFileInfoDataKey = "kFileInfoDataKey"
let kFileInfoNameKey = "kFileInfoNameKey"
let kFileInfoFileNameKey = "kFileInfoFileNameKey"
let kFileInfoMimeTypeKey = "kFileInfoMimeTypeKey"
 
struct WGURLRequestContext {
    var serverInfo: WGServerInfo
    var path: String?
    var user: String?
    var password: String?
    var method: String
    var parameters: [String:String]?
    var customHeader: [String:String]?
    var customBody: Data?
    var fileInfo: [String:AnyObject]?
    var connectIPAddress: String?
}
 
 extension WGURLRequestContext {
    
    init?(url: String) {
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
    
    func generateURLRequest() -> URLRequest {
        return generateURLRequest(allowCustomIP: true)
    }
    
    func generateURL() -> URL? {
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
