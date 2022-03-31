//
//  APIResponse.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

protocol APIResponseProtocol {
    associatedtype APIRequestResponseDataType //Tipo de dato que tendrán nuestros modelos de data
    func parseResponse(data: Data, response: HTTPURLResponse) throws -> APIRequestResponseDataType
}

extension APIResponseProtocol {
    func defaultParsedResponse<T: Decodable>(data: Data, response: HTTPURLResponse) throws -> T {
        let jsonDecoder = JSONDecoder()
        do {
            let body = try jsonDecoder.decode(T.self, from: data)
            
            switch response.statusCode {
                case 200..<300:
                    return body
                case 400..<500:
                    throw CustomError.api(type: .clientError(code: response.statusCode, endpoint: response.url!.absoluteString, parameters: ""))
                case 500..<600:
                    throw CustomError.api(type: .serverError(code: response.statusCode, endpoint: response.url!.absoluteString, parameters: ""))
                default:
                throw CustomError.api(type: .serverError(code: response.statusCode, endpoint: response.url!.absoluteString, parameters: ""))
            }
        } catch {
            throw CustomError.decodingUnknown(source: data.debugDescription)
        }
    }
}
