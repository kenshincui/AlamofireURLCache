//
//  AlamofireURLCache.swift
//  AlamofireURLCache
//
//  Created by Kenshin Cui on 2017/5/23.
//  Copyright © 2017年 CMJStudio. All rights reserved.
//

import Foundation
import CoreFoundation
import Alamofire

public struct AlamofireURLCache {
    public static var HTTPVersion = "HTTP/1.1" {
        didSet {
            if self.HTTPVersion.contains("1.0") {
                self.isCanUseCacheControl = false
            }
        }
    }
    
    
    /// If you customize the urlcache of urlsessionconfiguration, please set this property
    /// Default value is AF.session.configuration.urlCache == URLCache.shared
    public static var urlCache = AF.session.configuration.urlCache ?? URLCache.shared
    
    fileprivate static var isCanUseCacheControl = true
    
    fileprivate enum RefreshCacheValue:String {
        case refreshCache = "refreshCache"
        case useCache = "useCache"
    }
    fileprivate static let refreshCacheKey = "refreshCache"
    fileprivate static let frameworkName = "AlamofireURLCache"
}

extension Session {
    public func clearCache(request:URLRequest,urlCache:URLCache = AlamofireURLCache.urlCache) {
        if let cachedResponse = urlCache.cachedResponse(for: request) {
            if let httpResponse = cachedResponse.response as? HTTPURLResponse {
                let newData = cachedResponse.data
                guard let newURL = httpResponse.url else { return }
                guard let newHeaders = (httpResponse.allHeaderFields as NSDictionary).mutableCopy() as? NSMutableDictionary else { return }
                if AlamofireURLCache.isCanUseCacheControl {
                    DataRequest.addCacheControlHeaderField(headers: newHeaders, maxAge: 0, isPrivate: false)
                } else {
                    DataRequest.addExpiresHeaderField(headers: newHeaders, maxAge: 0)
                }
                if let newResponse = HTTPURLResponse(url: newURL, statusCode: httpResponse.statusCode, httpVersion: AlamofireURLCache.HTTPVersion, headerFields: newHeaders as? [String : String]) {
                    
                    let newCacheResponse = CachedURLResponse(response: newResponse, data: newData, userInfo: ["framework":AlamofireURLCache.frameworkName], storagePolicy: URLCache.StoragePolicy.allowed)
                    
                    urlCache.storeCachedResponse(newCacheResponse, for: request)
                }
            }
        }
    }
    
    public func clearCache(dataRequest:DataRequest,urlCache:URLCache = AlamofireURLCache.urlCache) {
        if let httpRequest = dataRequest.request {
            self.clearCache(request: httpRequest, urlCache: urlCache)
        }
    }
    
    public func clearCache(url:String,parameters:[String:Any]? = nil, headers:[String:String]? = nil,urlCache:URLCache = AlamofireURLCache.urlCache) {
        let httpHeaders = headers == nil ? nil : HTTPHeaders(headers!)
        if var urlRequest = try? URLRequest(url: url, method: HTTPMethod.get, headers: httpHeaders) {
            urlRequest.cachePolicy = .reloadIgnoringLocalCacheData
            if let newRequest = try? URLEncoding().encode(urlRequest, with: parameters) {
                self.clearCache(request: newRequest, urlCache: urlCache)
            }
        }
    }
}

extension Session {
    @discardableResult
    open func request(_ convertible: URLConvertible,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        encoding: ParameterEncoding = URLEncoding.default,
                        headers: HTTPHeaders? = nil,
                        interceptor: RequestInterceptor? = nil,
                        requestModifier: RequestModifier? = nil,
                        refreshCache:Bool = false) -> DataRequest {
        var newHeaders = headers
        if method == .get {
            if refreshCache {
                if newHeaders == nil {
                    newHeaders = HTTPHeaders()
                }
                if AlamofireURLCache.isCanUseCacheControl {
                    newHeaders?["Cache-Control"] = "no-cache"
                } else {
                    newHeaders?["Pragma"] = "no-cache"
                }
                newHeaders?[AlamofireURLCache.refreshCacheKey] = AlamofireURLCache.RefreshCacheValue.refreshCache.rawValue
                
            }
        }
        return request(convertible, method: method, parameters: parameters, encoding: encoding, headers: newHeaders, interceptor: interceptor, requestModifier: requestModifier)
    }
}

extension DataRequest {
    
    // MARK: - Public method
    @discardableResult
    public func cache(maxAge:Int,isPrivate:Bool = false,ignoreServer:Bool = true)
        -> Self
    {
        if maxAge <= 0 {
            return self
        }
        var useServerButRefresh = false
        if let newRequest = self.request {
            if !ignoreServer {
                if newRequest.allHTTPHeaderFields?[AlamofireURLCache.refreshCacheKey] == AlamofireURLCache.RefreshCacheValue.refreshCache.rawValue {
                    useServerButRefresh = true
                }
            }
            
            if newRequest.allHTTPHeaderFields?[AlamofireURLCache.refreshCacheKey] != AlamofireURLCache.RefreshCacheValue.refreshCache.rawValue {
                let urlCache = AlamofireURLCache.urlCache
                if let value = (urlCache.cachedResponse(for: newRequest)?.response as? HTTPURLResponse)?.allHeaderFields[AlamofireURLCache.refreshCacheKey] as? String {
                    if value == AlamofireURLCache.RefreshCacheValue.useCache.rawValue {
                        return self
                    }
                }
            }
        }
        
        // add to response queue wait for invoke
        return response { (defaultResponse) in
            
            if defaultResponse.request?.httpMethod != "GET" {
                debugPrint("Non-GET requests do not support caching!")
                return
            }
            

            if defaultResponse.error != nil {
                debugPrint(defaultResponse.error!.localizedDescription)
                return
            }

            if let httpResponse = defaultResponse.response {
                guard let newRequest = defaultResponse.request else { return }
                guard let newData = defaultResponse.data else { return }
                guard let newURL = httpResponse.url else { return }
                guard let newHeaders = (httpResponse.allHeaderFields as NSDictionary).mutableCopy() as? NSMutableDictionary else { return }
                let urlCache = AlamofireURLCache.urlCache
                if AlamofireURLCache.isCanUseCacheControl {
                    if httpResponse.allHeaderFields["Cache-Control"] == nil || (httpResponse.allHeaderFields["Cache-Control"] != nil && ( (httpResponse.allHeaderFields["Cache-Control"] as! String).contains("no-cache")
                         || (httpResponse.allHeaderFields["Cache-Control"] as! String).contains("no-store"))) || ignoreServer || useServerButRefresh {
                        if ignoreServer {
                            if newHeaders["Vary"] != nil { // http 1.1
                                newHeaders.removeObject(forKey: "Vary")
                            }
                            if newHeaders["Pragma"] != nil {
                                newHeaders.removeObject(forKey: "Pragma")
                            }
                        }
                        DataRequest.addCacheControlHeaderField(headers: newHeaders, maxAge: maxAge, isPrivate: isPrivate)
                    } else {
                        return
                    }
                } else {
                    if httpResponse.allHeaderFields["Expires"] == nil || ignoreServer || useServerButRefresh {
                        DataRequest.addExpiresHeaderField(headers: newHeaders, maxAge: maxAge)
                        if ignoreServer {
                            if httpResponse.allHeaderFields["Pragma"] != nil {
                                newHeaders["Pragma"] = "cache"
                            }
                            if newHeaders["Cache-Control"] != nil {
                                newHeaders.removeObject(forKey: "Cache-Control")
                            }
                        }
                    } else {
                        return
                    }
                }
                newHeaders[AlamofireURLCache.refreshCacheKey] = AlamofireURLCache.RefreshCacheValue.useCache.rawValue
                if let newResponse = HTTPURLResponse(url: newURL, statusCode: httpResponse.statusCode, httpVersion: AlamofireURLCache.HTTPVersion, headerFields: newHeaders as? [String : String]) {
                    
                    let newCacheResponse = CachedURLResponse(response: newResponse, data: newData, userInfo: ["framework":AlamofireURLCache.frameworkName], storagePolicy: URLCache.StoragePolicy.allowed)
                    
                    urlCache.storeCachedResponse(newCacheResponse, for: newRequest)
                }
            }
            
        }
        
    }
    
    @discardableResult
    public func response<Serializer: DataResponseSerializerProtocol>(queue: DispatchQueue = .main,
                                                                     responseSerializer: Serializer,
                                                                     completionHandler: @escaping (AFDataResponse<Serializer.SerializedObject>) -> Void,
                                                                     autoClearCache:Bool) -> Self  {
        let myCompleteHandler:((AFDataResponse<Serializer.SerializedObject>) -> Void) = {
            dataResponse in
            if dataResponse.error != nil && autoClearCache {
                if let request = dataResponse.request {
                    AF.clearCache(request: request)
                }
            }
            completionHandler(dataResponse)
        }
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: myCompleteHandler)
    }
    
    @discardableResult
    public func responseData(queue: DispatchQueue = .main,
                             dataPreprocessor: DataPreprocessor = DataResponseSerializer.defaultDataPreprocessor,
                             emptyResponseCodes: Set<Int> = DataResponseSerializer.defaultEmptyResponseCodes,
                             emptyRequestMethods: Set<HTTPMethod> = DataResponseSerializer.defaultEmptyRequestMethods,
                             completionHandler: @escaping (AFDataResponse<Data>) -> Void,
                             autoClearCache:Bool) -> Self {
        response(queue: queue,
                 responseSerializer: DataResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                            emptyResponseCodes: emptyResponseCodes,
                                                            emptyRequestMethods: emptyRequestMethods),
                 completionHandler: completionHandler, autoClearCache: autoClearCache)
    }
    
    @discardableResult
    public func responseString(queue: DispatchQueue = .main,
                               dataPreprocessor: DataPreprocessor = StringResponseSerializer.defaultDataPreprocessor,
                               encoding: String.Encoding? = nil,
                               emptyResponseCodes: Set<Int> = StringResponseSerializer.defaultEmptyResponseCodes,
                               emptyRequestMethods: Set<HTTPMethod> = StringResponseSerializer.defaultEmptyRequestMethods,
                               completionHandler: @escaping (AFDataResponse<String>) -> Void,
                               autoClearCache:Bool) -> Self {
        response(queue: queue,
                 responseSerializer: StringResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                              encoding: encoding,
                                                              emptyResponseCodes: emptyResponseCodes,
                                                              emptyRequestMethods: emptyRequestMethods),
                 completionHandler: completionHandler, autoClearCache: autoClearCache)
    }
    
    @discardableResult
    public func responseJSON(queue: DispatchQueue = .main,
                             dataPreprocessor: DataPreprocessor = JSONResponseSerializer.defaultDataPreprocessor,
                             emptyResponseCodes: Set<Int> = JSONResponseSerializer.defaultEmptyResponseCodes,
                             emptyRequestMethods: Set<HTTPMethod> = JSONResponseSerializer.defaultEmptyRequestMethods,
                             options: JSONSerialization.ReadingOptions = .allowFragments,
                             completionHandler: @escaping (AFDataResponse<Any>) -> Void,
                             autoClearCache:Bool) -> Self {
        response(queue: queue,
                 responseSerializer: JSONResponseSerializer(dataPreprocessor: dataPreprocessor,
                                                            emptyResponseCodes: emptyResponseCodes,
                                                            emptyRequestMethods: emptyRequestMethods,
                                                            options: options),
                 completionHandler: completionHandler, autoClearCache: autoClearCache)
    }
    
    // MARK: - Private method
    fileprivate static func addCacheControlHeaderField(headers:NSDictionary,maxAge:Int,isPrivate:Bool) {
        var cacheValue = "max-age=\(maxAge)"
        if isPrivate {
            cacheValue += ",private"
        }
        headers.setValue(cacheValue, forKey: "Cache-Control")
    }
    
    fileprivate static func addExpiresHeaderField(headers:NSDictionary,maxAge:Int) {
        guard let dateString = headers["Date"] as? String else { return }
        let formate = DateFormatter()
        formate.dateFormat = "E, dd MMM yyyy HH:mm:ss zzz"
        formate.timeZone = TimeZone(identifier: "UTC")
        guard let date = formate.date(from: dateString) else { return }
        let expireDate = Date(timeInterval: TimeInterval(maxAge), since: date)
        let cacheValue = formate.string(from: expireDate)
        headers.setValue(cacheValue, forKey: "Expires")
    }

}
