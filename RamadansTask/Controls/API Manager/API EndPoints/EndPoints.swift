//
//  EndPoints.swift
//  RamadansTask
//
//  Created by Feras Almahsere on 3/16/20.
//  Copyright © 2020 Feras Almahsere. All rights reserved.
//

import Foundation
import Alamofire

enum EndPoints: URLRequestConvertible {
    
    case getUserInfo(userName: String)
    case getUserFollowers(userName: String, page: Int)
    
    var method: HTTPMethod {
        switch self {
        case .getUserInfo(_): return .get
        case .getUserFollowers(_): return .get
            
        }
    }
    
    var debugDescription: String {
        return ""
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .getUserInfo(let userName): return userName
        case .getUserFollowers(let userName, _): return userName + "/followers"
            
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .getUserInfo(_):
            return nil
        case .getUserFollowers(_ , let page):
            return ["page": page, "per_page":4]
        }
    }
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        
        guard let url = URL(string: "https://api.github.com/users/") else {
            fatalError("Root URL is invalid")
        }
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        print("Sending Request with URL:\(url.debugDescription) and params:\(parameters ?? Dictionary())")
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        
        if let params = parameters {
            do {
                switch self {
                case .getUserInfo, .getUserFollowers:
                    urlRequest = try URLEncoding.queryString.encode(urlRequest, with: params)
                }
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        return urlRequest
    }
}
