//
//  ItemViewModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation
import RxSwift

class ItemViewModel {
    //Inputs
    private var itemProvider:ItemProviderProtocol!
    private var descriptionProvider:ItemDescriptionProviderProtocol!
    private var disposeBag = DisposeBag()
    //Outputs
    var title: String = ""
    var price: String = ""
    var conditionAndSoldQty: String = ""
    var sellerAddress: String = ""
    var picturesUrl: [String] = []
    var warranty: String = ""
    var description: String = ""
    var numberOfImages = 0
    var numberOfAttributes = 0
    var isLiked = false
    
    var loadItemData = PublishSubject<Void>()
    var loadItemDescription = PublishSubject<Void>()
    var selectedItemIdSubject = PublishSubject<String>()
    var showLoadingSubject = PublishSubject<Bool>()
    var likeItemSubject = PublishSubject<Void>()
    var showLikedSubject = PublishSubject<Bool>()
    
    private var currentItem:ItemModel!
    private var attributesDataSource:[ItemAttributesViewModel] = []
    
    init(itemProvider: ItemProviderProtocol = ItemProvider(), descriptionProvider: ItemDescriptionProviderProtocol = ItemDescriptionProvider()) {
        self.itemProvider = itemProvider
        self.descriptionProvider = descriptionProvider
        initialize()
    }
    
    func initialize(){
        
        selectedItemIdSubject
            .asObservable()
            .do(onNext: { _ in
                self.showLoadingSubject.onNext(true)
            })
            .subscribe(onNext: { itemId in
                self.getItemDetails(id: itemId)
                self.getItemDescription(itemId: itemId)
            })
            .disposed(by: disposeBag)
                
            likeItemSubject
                .asObservable()
                .flatMapLatest({ _ -> Observable<Bool> in
                    return self.toggleLikeStateForItem()
                })
                .subscribe(onNext:{ liked in
                    self.showLikedSubject.onNext(liked)
                }).disposed(by: disposeBag)
    }
    
    private func getItemDetails(id: String){
        itemProvider.getItemById(itemId: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                self.currentItem = model
                self.prepareDataForView()
                self.loadItemData.onNext(())
                self.loadItemData.onCompleted()
                self.showLoadingSubject.onNext(false)
            case .failure(let error):
                self.loadItemData.onError(error)
            }
        }
    }
    
    private func getItemDescription(itemId: String){
        descriptionProvider.getDescription(for: itemId) {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                self.description = model.content
                self.loadItemDescription.onNext(())
                self.loadItemDescription.onCompleted()
            case .failure(let error):
                self.loadItemDescription.onError(error)
                print("ItemViewModel - getItemDescription(id:\(itemId)) -> Error: \(error)\n")
            }
        }
    }
    
    private func prepareDataForView(){
        title = getItemTitle()
        price = getItemPrice()
        conditionAndSoldQty = getItemConditionAndSoldQuatity()
        sellerAddress = getItemSellerAddress()
        picturesUrl = getItemPicturesUrl()
        warranty = getItemWarranty()
        numberOfImages = picturesUrl.count
        
        let attributes = getItemAttributes() //filter and ignore those with null value name
        attributesDataSource = attributes.map({ ItemAttributesViewModel(itemAttributeModel: $0) })
        numberOfAttributes = attributesDataSource.count
        
        self.showLikedSubject.onNext(isItemLiked())
    }
    
    private func toggleLikeStateForItem() -> Observable<Bool> {
        Observable.create { [self] observer -> Disposable in
                       
            if Constants.userDefaults.bool(forKey:currentItem.id) {
                Constants.userDefaults.removeObject(forKey: currentItem.id)
                Constants.userDefaults.synchronize()
                print("unlike an item \(currentItem.id)")
                observer.onNext(false)
                observer.onCompleted()
            }else{
                print("like an item \(currentItem.id)")
                Constants.userDefaults.set(true, forKey: currentItem.id)
                Constants.userDefaults.synchronize()
                observer.onNext(true)
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func getItemTitle() -> String {
        return currentItem.title
    }
    
    private func getItemPrice() -> String {
        return NumberFormatter.currencyFormatter.string(from: currentItem.price as NSNumber)!
    }
    
    private func getItemConditionAndSoldQuatity() -> String {
        let condition = (currentItem.condition == "new") ? "Nuevo" : "Usado"
        let quantity = (currentItem.soldQuantity > 0) ? " | \(currentItem.soldQuantity) vendidos" : ""
        return "\(condition) \(quantity)"
    }
    
    private func getItemSellerAddress() -> String {
        return "\(currentItem.sellerAddress.city.name), \(currentItem.sellerAddress.state.name)"
    }
    
    private func getItemAttributes() -> [ItemAttribute] {
        let filteredAttributes = currentItem.attributes.filter({$0.valueName != nil})
        let sliceAttributes = Array(filteredAttributes.prefix(6))
        return sliceAttributes
    }
    
    private func getItemPicturesUrl() -> [String] {
        return currentItem.pictures.map { $0.secureURL }
    }
    
    private func getItemWarranty() -> String {
        return (currentItem.warranty != nil) ? currentItem.warranty! : "Sin garantía"
    }
    
    private func prefetchImages() {
        _ = currentItem.pictures.map { UIImageView().getImageFromURL(imageURLString: $0.secureURL) }
    }
    
    func getViewModelForCell(indexPathRow: Int) -> ItemAttributesViewModel {
        return attributesDataSource[indexPathRow]
    }
    
    func getImageUrlForCell(indexPathRow: Int) -> String {
        return currentItem.pictures[indexPathRow].secureURL
    }
    
    func openPermalinkToItem() {
        if let permalink = URL(string: currentItem.permalink) {
            UIApplication.shared.open(permalink)
        }
    }
    
    private func isItemLiked() -> Bool {
        return Constants.userDefaults.bool(forKey:currentItem.id)
    }
    
}

struct ItemAttributesViewModel {
    
    //Input: Search results model
    var itemAttribute:ItemAttribute!
    //Outputs: Processed Data to feed the table cell
    var attributeKey: String = ""
    var attributeValue: String = ""
    
    init(itemAttributeModel: ItemAttribute) {
        itemAttribute = itemAttributeModel
        configureOutputForCell()
    }
 
    mutating func configureOutputForCell(){
        attributeKey = itemAttribute.name
        attributeValue = itemAttribute.valueName!
        //can force unwrap because previously filtered those with valueName=nil
    }
    
}

