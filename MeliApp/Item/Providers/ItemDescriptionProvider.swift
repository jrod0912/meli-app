//
//  ItemDescriptionProvider.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 2/04/22.
//

import Foundation

protocol ItemDescriptionProviderProtocol {
    func getDescription(for itemId:String, completion: @escaping (Result<ItemDescriptionModel, Error>) -> ())
}

struct ItemDescriptionProvider: ItemDescriptionProviderProtocol {
    
    let manager = APIServiceManager(service: ItemDescriptionService())
    
    func getDescription(for itemId: String, completion: @escaping (Result<ItemDescriptionModel, Error>) -> ()) {
        manager.performAPIRequest(with: itemId) { (results, error) in
            guard error == nil, let _ = results else {
                return completion(.failure(error!))
            }
            
            if let model = results {
                completion(.success(model))
            }
        }
    }
}

struct MockItemDescriptionProvider: ItemDescriptionProviderProtocol, MockProviderProtocol {
    
    var jsonFileName:String = "itemDescription"
    
    func getDescription(for itemId: String, completion: @escaping (Result<ItemDescriptionModel, Error>) -> ()) {
        let fileName = jsonFileName
        MockItemProvider.loadJsonDataFromFile(fileName, completion: { data in
            //TODO: Mover logica para decoder en general
            if let json = data {
                do {
                    let decodedJson = try JSONDecoder().decode(ItemDescriptionModel.self, from: json)
                    completion(.success(decodedJson))
                }catch DecodingError.keyNotFound(let key, let context) {
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
