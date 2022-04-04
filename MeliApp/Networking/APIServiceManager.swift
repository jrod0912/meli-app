//
//  APIServiceManager.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

//Tipo de dato que indica que todos los servicios deben implementar ambos protocolos
typealias APIService = APIRequestProtocol & APIResponseProtocol

class APIServiceManager <T:APIService> {
    
    let service: T
    let urlSession: URLSession
    
    init(service: T, urlSession: URLSession = .shared){
        self.service = service
        self.urlSession = urlSession
    }
    
    func performAPIRequest(with requestParameters: T.APIRequestParametersType, completionHandler: @escaping (T.APIRequestResponseDataType?, Error?) -> ()) {
        if let urlRequest = service.createRequest(with: requestParameters) {
            urlSession.dataTask(with: urlRequest) { (data, response, error) in
                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    return completionHandler(nil, error)
                }
                do {
                    let parsedResponse = try self.service.parseResponse(data: data, response: httpResponse)
                    completionHandler(parsedResponse, nil)
                }
                catch {
                    completionHandler(nil, error)
                }
            }.resume()
        }
    }
}
