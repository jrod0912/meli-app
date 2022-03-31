//
//  ItemProvider.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

protocol ItemProviderProtocol {
    func getItemById(itemId:String, completion: @escaping (Result<ItemModel, Error>) -> ())
}

struct ItemProvider: ItemProviderProtocol {
    
    let manager = APIServiceManager(service: ItemService())
    
    func getItemById(itemId:String, completion: @escaping (Result<ItemModel, Error>) -> ()) {
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

struct MockItemProvider: ItemProviderProtocol, MockProviderProtocol {
    
    var jsonFileName:String = "itemDetails"
    
    func getItemById(itemId:String, completion: @escaping (Result<ItemModel, Error>) -> ()) {
        let fileName = jsonFileName
        MockItemProvider.loadJsonDataFromFile(fileName, completion: { data in
            //TODO: Mover logica para decoder en general
            if let json = data {
                do {
                    let decodedJson = try JSONDecoder().decode(ItemModel.self, from: json)
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

enum DecodeError: Error, Equatable {
    case typeMismatch
    case keyNotFound
    case valueNotFound
    case dataCorrupted
    case unknownError
}

extension DecodeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .typeMismatch:
            return NSLocalizedString("Type mismatch.",comment: "Type mismatch")
        case .keyNotFound:
            return NSLocalizedString("Failed to decode data from bundle, missing key.",comment: "Key Not Found")
        case .valueNotFound:
            return NSLocalizedString("Failed to decode data from bundle, missing value.",comment: "Value Not Found")
        case .dataCorrupted:
            return NSLocalizedString("Invalid JSON.",comment: "Data Corrupted")
        case .unknownError:
            return NSLocalizedString("Failed to decode JSON.",comment: "Unexpected Error")
        }
    }
}