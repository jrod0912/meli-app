//
//  SearchResultViewModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 4/04/22.
//

import Foundation

struct SearchResultViewModel {
    
    //Input: Search results data model
    var searchResult:SearchResult!
    //Outputs: Processed data to feed the tableview cell
    var id: String = ""
    var title: String = ""
    var thumbnailUrl: String = ""
    var price: String = ""
    var installments:String = ""
    var hasFreeShipping: String = ""
 
    init(searchResultModel: SearchResult) {
        searchResult = searchResultModel
        configureOutputForCell()
    }
 
    mutating func configureOutputForCell(){
        id = getItemId()
        thumbnailUrl = getItemThumbnailUrl()
        title = getItemTitle()
        price = getItemPrice()
        installments = getItemInstallments()
        hasFreeShipping = getItemFreeShipping()
    }
    
    private func getItemId() -> String {
        return searchResult.id
    }
    
    private func getItemTitle() -> String {
        return searchResult.title
    }
    
    private func getItemPrice() -> String {
        return NumberFormatter.currencyFormatter.string(from: searchResult.price as NSNumber)!
    }
    
    private func getItemInstallments() -> String {
        guard let installments = searchResult.installments else { return ""}
        let quantity = "\(installments.quantity)"
        let amount = NumberFormatter.currencyFormatter.string(from: installments.amount as NSNumber)!
        return Constants.PlaceholderText.INSTALLMENTS_PLACEHOLDER
            .replacingOccurrences(of: "{cantidad_cuotas}", with: quantity)
            .replacingOccurrences(of: "{monto_cuotas}", with: amount)
    }
    
    private func getItemFreeShipping() -> String {
        let hasFreeShipping = searchResult.shipping.freeShipping
        return (hasFreeShipping) ? Constants.PlaceholderText.FREE_SHIPPING_PLACEHOLDER : ""
    }
    
    private func getItemThumbnailUrl() -> String {
        return searchResult.thumbnail
    }
}
