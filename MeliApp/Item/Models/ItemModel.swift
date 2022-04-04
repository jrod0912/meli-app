//
//  ItemModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation

struct ItemModel: Codable, Equatable {
        
    let id: String
    let title: String
    let sellerId: Int
    let price: Int
    let initialQuantity: Int
    let availableQuantity: Int
    let soldQuantity: Int
    let condition: String
    let permalink: String
    let pictures: [ItemPicture]
    let shipping: ItemShipping
    let sellerAddress: ItemSellerAddress
    let attributes: [ItemAttribute]
    let warranty: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case sellerId = "seller_id"
        case price
        case initialQuantity = "initial_quantity"
        case availableQuantity = "available_quantity"
        case soldQuantity = "sold_quantity"
        case condition
        case permalink
        case pictures
        case shipping
        case sellerAddress = "seller_address"
        case attributes
        case warranty
    }
}

struct ItemPicture: Codable,Equatable {
    let id: String
    let secureURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case secureURL = "secure_url"
    }
}

struct ItemShipping: Codable, Equatable {
    let freeShipping: Bool

    enum CodingKeys: String, CodingKey {
        case freeShipping = "free_shipping"
    }
}

struct ItemSellerAddress: Codable, Equatable {
    let city, state : ItemAddressCity

    enum CodingKeys: String, CodingKey {
        case city, state
    }
}

struct ItemAddressCity: Codable, Equatable {
    let id, name: String
}

struct ItemAttribute: Codable, Equatable {
    let id, name: String
    let valueName: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case valueName = "value_name"
    }
}
