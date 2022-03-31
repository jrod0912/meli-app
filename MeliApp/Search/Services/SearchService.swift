//
//  SearchService.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

struct SearchService: APIService {
    
    typealias APIRequestParametersType = [String:Any]
    
    func createRequest(with params: [String:Any]) -> URLRequest? {
        let urlString = APIConstants.getEndpointURLString(endpoint: .searchItems)
        if var url = URL(string: urlString) {
            if !params.isEmpty {
                url = setQueryParameters(parameters: params, url: url)
            }
            var urlRequest = URLRequest(url: url)
            setDefaultHeaders(request: &urlRequest)
            urlRequest.httpMethod = APIConstants.HTTPMethod.GET.rawValue
            return urlRequest
        }
        return nil
    }
    
    func parseResponse(data: Data, response: HTTPURLResponse) throws -> SearchModel {
        return try defaultParsedResponse(data: data, response: response)
    }
}
