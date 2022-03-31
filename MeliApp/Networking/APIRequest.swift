//
//  APIRequest.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

protocol APIRequestProtocol {
    associatedtype APIRequestParametersType //Tipo de dato de los parametros requeridos para armar el request en ocasiones puede ser sólo un String o algo como [String,Any]
    func createRequest(with parameters: APIRequestParametersType) -> URLRequest?
}

extension APIRequestProtocol {
    
    func setBodyParameters(parameters: [String:Any], urlRequest: inout URLRequest) {
        guard !parameters.isEmpty else { print("No body parameters were sent")
            return
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: []){
            urlRequest.httpBody = jsonData
        }
    }
    
    func setQueryParameters(parameters: [String:Any], url: URL) -> URL {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = parameters.map {element in URLQueryItem(name: element.key, value: String(describing:element.value))}
        return components?.url ?? url
    }
    
    func setDefaultHeaders(request: inout URLRequest) {
        request.setValue(APIConstants.Headers.contentTypeValue, forHTTPHeaderField: APIConstants.Headers.contentTypeKey)
    }
}
