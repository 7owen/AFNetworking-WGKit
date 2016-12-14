//
//  WGURLSession.swift
//  Sample
//
//  Created by 7owen on 2016/12/14.
//  Copyright © 2016年 7owen. All rights reserved.
//

import UIKit
import AFNetworking

typealias WGURLSessionEditRequest = (URLRequest) -> URLRequest
typealias WGURLSessionCompletionHandler = (HTTPURLResponse?, Any?, Error?) -> Void
typealias WGURLSessionErrorPreHandler = (HTTPURLResponse?, Any?, Error?) -> Error
typealias WGURLSessionResponsePreHandler = (HTTPURLResponse?, Any?, Error?) -> Any

protocol WGURLSessionDomainResolution {
    func query(with domain: String) -> String?
}

final class WGURLSession: NSObject {
    static var defaultManager: AFHTTPSessionManager?
    static var defaultErrorHandlerBlock: WGURLSessionErrorPreHandler?
    static var defaultResponseHandlerBlock: WGURLSessionResponsePreHandler?
    
    static func request<T:WGURLSessionRequest>(_ request: T, sessionManager: AFHTTPSessionManager? = defaultManager, errorPreHandler: WGURLSessionErrorPreHandler? = defaultErrorHandlerBlock, responsePreHandler:WGURLSessionResponsePreHandler? = defaultResponseHandlerBlock, domainResolution: WGURLSessionDomainResolution? = nil, completionHandler:@escaping WGURLSessionCompletionHandler) {
        
        var urlRequest:URLRequest?
        switch request {
        case let request as URLRequest:
            if let domainResolution = domainResolution {
                var mRequest = request
                if  let url = request.url, let host = url.host, let ip = domainResolution.query(with: host) {
                    mRequest.addValue(host, forHTTPHeaderField: "Host")
                    let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
                    urlComponents?.host = ip
                    mRequest.url = urlComponents?.url
                }
                urlRequest = mRequest
            }
        case var requestContext as WGURLRequestContext:
            if let domainResolution = domainResolution, let host = requestContext.serverInfo.host {
                requestContext.connectIPAddress = domainResolution.query(with:host)
            }
            urlRequest = requestContext.generateURLRequest()
        default:()
        }
        if let request = urlRequest {
            var manager:AFHTTPSessionManager
            if sessionManager != nil {
                manager = sessionManager!
            } else {
                manager = AFHTTPSessionManager()
            }
            
            let task = manager.dataTask(with: request, completionHandler: { (response, responseObj, error) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    completionHandler(nil,nil,nil)
                    return
                }
                if error == nil {
                    var aResponseObj = responseObj
                    if let responseHandlerBlock = responsePreHandler {
                        aResponseObj = responseHandlerBlock(httpResponse, responseObj, error)
                    }
                    completionHandler(httpResponse, aResponseObj, error)
                } else {
                    var aError = error
                    if let errorHandlerBlock = errorPreHandler {
                        aError = errorHandlerBlock(httpResponse, responseObj, error)
                    }
                    completionHandler(nil,nil,aError)
                }
            })
            task.resume()
        } else {
            completionHandler(nil,nil,nil)
        }
    }
}

protocol WGURLSessionRequest {
    
}

extension URLRequest: WGURLSessionRequest {
    
}

extension WGURLRequestContext: WGURLSessionRequest {
    
}
