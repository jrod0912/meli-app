//
//  ItemService.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

struct ItemService: APIService {
    
    typealias APIRequestParametersType = String
    
    func createRequest(with id: String) -> URLRequest? {
        let urlString = APIConstants.getEndpointURLString(endpoint: .getItem).replacingOccurrences(of: "{itemId}", with: id)
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            setDefaultHeaders(request: &urlRequest)
            urlRequest.httpMethod = APIConstants.HTTPMethod.GET.rawValue
            return urlRequest
        }
        return nil
    }
    
    func parseResponse(data: Data, response: HTTPURLResponse) throws -> ItemModel {
        return try defaultParsedResponse(data: data, response: response)
    }
}
