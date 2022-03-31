//
//  Errors.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 30/03/22.
//

import Foundation

enum CustomError: Error {
    
    case decodingUnknown(source:String)
    case api(type: APIError)
    case validation(type: ValidationError)
    case search(type: SearchError)
    
    enum ValidationError {
        case isEmpty(field: String)
    }
    
    enum APIError {
        case clientError(code: Int, endpoint: String, parameters: String)
        case serverError(code: Int, endpoint: String, parameters: String)
    }
    
    enum SearchError {
        case notFound
    }

}

extension CustomError: LocalizedError {
    var errorDescription: String?{
        switch self {
            case .decodingUnknown(source: let filename):
                return NSLocalizedString("Failed to decode \(filename).json from bundle", comment: "Unknown error")
            case .validation(type: let type):
                switch type {
                    case .isEmpty(field: let fieldname):
                        return NSLocalizedString("\(fieldname) cannot be empty.", comment: "")
        }
        
        case .api(type: let type):
            switch type {
                case .clientError(code: let code, endpoint: let endpoint, parameters: let parameters):
                    return NSLocalizedString("APIError when performing request: \(endpoint) with parameters (\(parameters)) responded with status code \(code)", comment: "")
                case .serverError(code: let code, endpoint: let endpoint, parameters: let parameters):
                    return NSLocalizedString("APIError when performing request: \(endpoint) with parameters (\(parameters)) responded with status code \(code)", comment: "")
            }
        
        case .search(type: let type):
            switch type {
                case .notFound:
                    return NSLocalizedString("No results found for this search!" , comment: "")
                }
        }
    }
}
