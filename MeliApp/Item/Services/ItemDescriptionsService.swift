//
//  ItemDescriptionsService.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 2/04/22.
//

import Foundation

struct ItemDescriptionService: APIService {
    
    typealias APIRequestParametersType = String
    
    func createRequest(with id: String) -> URLRequest? {
        let urlString = APIConstants.getEndpointURLString(endpoint: .getItemDescription).replacingOccurrences(of: "{itemId}", with: id)
        if let url = URL(string: urlString) {
            var urlRequest = URLRequest(url: url)
            setDefaultHeaders(request: &urlRequest)
            urlRequest.httpMethod = APIConstants.HTTPMethod.GET.rawValue
            return urlRequest
        }
        return nil
    }
    
    func parseResponse(data: Data, response: HTTPURLResponse) throws -> ItemDescriptionModel {
        return try defaultParsedResponse(data: data, response: response)
    }
}
