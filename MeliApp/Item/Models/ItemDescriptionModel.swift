//
//  ItemDescriptionModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 2/04/22.
//

import Foundation

struct ItemDescriptionModel: Codable, Equatable {
    
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case content = "plain_text"
    }
}
