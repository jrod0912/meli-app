//
//  SearchProvider.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

protocol SearchProviderProtocol {
    func getSearchResultsFor(query: String, with offset: Int, completion: @escaping (Result<SearchModel, Error>) -> ())
}

struct SearchProvider: SearchProviderProtocol {
    
    let manager = APIServiceManager(service: SearchService())
    
    func getSearchResultsFor(query: String, with offset: Int, completion: @escaping (Result<SearchModel, Error>) -> ()) {
        let parameters:[String:Any] = ["q":query, "offset": offset]
        manager.performAPIRequest(with: parameters) { (results, error) in
            guard error == nil, let _ = results else {
                return completion(.failure(CustomError.search(type: .notFound)))
            }
            
            if let model = results {
                completion(.success(model))
            }
        }
    }
}

struct MockSearchProvider: SearchProviderProtocol, MockProviderProtocol {
    
    var jsonFileName:String!
    
    init(jsonFileName: String) {
        self.jsonFileName = jsonFileName
    }
    
    func getSearchResultsFor(query: String, with offset: Int, completion: @escaping (Result<SearchModel, Error>) -> ()) {
        
        guard let fileName = jsonFileName else { return }
        
        MockSearchProvider.loadJsonDataFromFile(fileName, completion: { data in
            if let json = data {
                do {
                    let decodedJson = try JSONDecoder().decode(SearchModel.self, from: json)
                    completion(.success(decodedJson))
                } catch DecodingError.keyNotFound(let key, let context) {
                    completion(.failure(DecodingError.keyNotFound(key,context)))
                } catch DecodingError.typeMismatch(let type, let context) {
                    completion(.failure(DecodingError.typeMismatch(type, context)))
                } catch DecodingError.valueNotFound(let type, let context) {
                    completion(.failure(DecodingError.valueNotFound(type, context)))
                }  catch DecodingError.dataCorrupted(let context) {
                    completion(.failure(DecodingError.dataCorrupted(context)))
                } catch {
                    completion(.failure(CustomError.decodingUnknown(source: fileName)))
                }
            }
        })
    }
}
