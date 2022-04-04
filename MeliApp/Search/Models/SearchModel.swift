//
//  SearchModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 26/03/22.
//

import Foundation

struct SearchModel: Codable, Equatable {
    static func == (lhs: SearchModel, rhs: SearchModel) -> Bool {
        return lhs.query == rhs.query && lhs.results == rhs.results && lhs.paging == rhs.paging
    }
    
    let query: String
    let results: [SearchResult]
    let paging: SearchPaging
}

struct SearchResult: Codable, Equatable {
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.price == rhs.price &&
        lhs.condition == rhs.condition &&
        lhs.thumbnail == rhs.thumbnail &&
        lhs.installments == rhs.installments &&
        lhs.shipping == rhs.shipping
    }
    
    let id, title: String
    let price: Int
    let condition: String
    let thumbnail: String
    let installments: SearchResultInstallment?
    let shipping: SearchResultShipping
}

struct SearchResultInstallment: Codable, Equatable {
    let quantity: Int
    let amount: Double
    let rate: Int
}

struct SearchResultShipping: Codable, Equatable {
    let freeShipping: Bool
    
    enum CodingKeys: String, CodingKey {
        case freeShipping = "free_shipping"
    }
}

struct SearchPaging: Codable, Equatable {
    let total: Int
    let offset: Int
    let limit: Int
}
