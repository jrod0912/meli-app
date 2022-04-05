//
//  MockProviderProtocol.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

protocol MockProviderProtocol {
    var jsonFileName:String! { get set }
    init(jsonFileName: String)
    static func loadJsonDataFromFile(_ path: String, completion: (Data?) -> Void)
}

extension MockProviderProtocol{
    static func loadJsonDataFromFile(_ path: String, completion: (Data?) -> Void) {
        if let fileUrl = Bundle.main.url(forResource: path, withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                completion(data as Data)
            } catch (let error) {
                Log.event(type: .error, "Failed to load data from json file, reason: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
