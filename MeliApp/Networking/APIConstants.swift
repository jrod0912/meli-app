//
//  APIConstants.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

struct APIConstants {
    
    static let baseURL: String = "https://api.mercadolibre.com/"
    
    enum Endpoints: String {
        case searchItems = "sites/MCO/search"
        case getItem = "items/{itemId}"
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    struct Headers {
        static var contentTypeKey = "Content-Type"
        static var contentTypeValue = "application/json"
    }
    
    static func getEndpointURLString(endpoint: Endpoints) -> String {
        return baseURL + endpoint.rawValue
    }
}
