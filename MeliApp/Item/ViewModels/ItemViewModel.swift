//
//  ItemViewModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation
import RxSwift

class ItemViewModel {
    // TODO: Add loading and error views
    private var provider:ItemProviderProtocol!
    private var disposeBag = DisposeBag()
    var selectedItemIdSubject = PublishSubject<String>()
    var itemDetails = PublishSubject<ItemModel>()
    var selectedItem:ItemModel!
    
    init(provider: ItemProviderProtocol = ItemProvider()) {
        self.provider = provider
    }
    
    func getItemDetails(id: String){
        provider.getItemById(itemId: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                self.selectedItem = model
                self.itemDetails.onNext(model)
                self.itemDetails.onCompleted()
            case .failure(let error):
                print("ItemViewModel - getItemDetails(id:\(id)) -> Error: \(error)\n")
                self.itemDetails.onError(error)
            }
        }
    }
    
    func getItemTitle() -> String {
        return selectedItem.title
    }
    
    func getItemPrice() -> String {
        return NumberFormatter.currencyFormatter.string(from: selectedItem.price as NSNumber)!
    }
    
    func getItemConditionAndSoldQuatity() -> String {
        let condition = (selectedItem.condition == "new") ? "Nuevo" : "Usado"
        let quantity = (selectedItem.soldQuantity > 0) ? " | \(selectedItem.soldQuantity) vendidos" : ""
        return "\(condition) \(quantity)"
    }
    
    func getItemSellerAddress() -> String {
        return "\(selectedItem.sellerAddress.city.name), \(selectedItem.sellerAddress.state.name)"
    }
    
    func getItemAttributes() -> [ItemAttribute] {
        let filteredAttributes = selectedItem.attributes.filter({$0.valueName != nil})
        let sliceAttributes = Array(filteredAttributes.prefix(6))
        return sliceAttributes
    }
    
    func getItemPicturesUrl() -> [String] {
        return selectedItem.pictures.map { $0.secureURL }
    }
    
    func getItemWarranty() -> String {
        return (selectedItem.warranty != nil) ? selectedItem.warranty! : "Sin garantía"
    }
    
    func openPermalinkToItem() {
        if let permalink = URL(string: selectedItem.permalink) {
            UIApplication.shared.open(permalink)
        }
    }
    
}

