//
//  APIError.swift
//  RamadansTask
//
//  Created by Feras Almahsere on 3/16/20.
//  Copyright © 2020 Feras Almahsere. All rights reserved.
//

import Foundation

struct NetworkError: Codable {
    let errors: [String]
    
    enum CodingKeys: String, CodingKey {
        case errors = "error"
    }
}

enum APIError: Error {
    case offline, server, forbidden, notFound, timedOut, internalServerError, failedToCommunicateWithServer, badResponse, other(Error, data: Data?)
}

extension APIError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .offline:
            return NSLocalizedString("The Internet connection appears to be offline", comment: "No internet connection the rquest couldn't proceed")
        case .server:
            return NSLocalizedString("There was a problem reaching the server.. please try again later", comment: "Server is not responding error")
        case .timedOut:
            return NSLocalizedString("Request timed out.. please try again later", comment: "Request is taking long time more than usual")
        case .internalServerError:
            return NSLocalizedString("There was a problem reaching the servers.. please contact the system admin.", comment: "Reaching server error")
        case .failedToCommunicateWithServer:
            return NSLocalizedString("There was an error communicating with the servers.. please contact the system admin.", comment: "Failed to communicate with server Why this might have happened: - The server couldn\'t send a response: Ensure that the backend is working properly - Self-signed SSL certificates are being blocked: - Fix this by turning - Ensure that proxy is configured correctly in Settings > Proxy")
        case .badResponse:
            return NSLocalizedString("Unexcpected error (bad response).. please contact the system admin.", comment: "Unexcpected server response (bad response)")
        case .notFound:
            return NSLocalizedString("Unexcpected error (404).. please contact the system admin.", comment: "Unexcpected server response (404) the API is not found")
        case .forbidden:
            return NSLocalizedString("Unexcpected error (403).. please contact the system admin.", comment: "Unexcpected server response (403) the server has frobeddin the request")
        case .other(let error, data: let data):
                        
            if let data = data{
                let decoder = JSONDecoder()
                if let networkError = try? decoder.decode(NetworkError.self, from: data) {
                    return networkError.errors.joined(separator: ", ")
                }
                
                let str = String(data: data, encoding: String.Encoding.utf8)
                return str ?? ""
            }else{
                return error.localizedDescription
            }
            
        }
    }
}
