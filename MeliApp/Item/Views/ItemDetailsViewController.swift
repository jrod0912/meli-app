//
//  ItemDetailsViewController.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 29/03/22.
//

import UIKit
import RxSwift
import RxCocoa

class ItemDetailsViewController: UIViewController {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var conditionAndSoldQuantity: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var sellerAddress: UILabel!
    @IBOutlet weak var itemWarranty: UILabel!
    @IBOutlet weak var itemAttributesTable: UITableView!
    @IBOutlet weak var imageCarousel: UICollectionView!
    
    private var disposeBag = DisposeBag()
    private var viewModel = ItemViewModel()
    private var itemImagesURL:[String] = []
    private var itemAttributes:[ItemAttribute] = []
    
    var selectedItemId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getItemDetails(id: selectedItemId)
        //TODO: Suscriptions (faltan like, comprar = llevar a la web)
        loadItemDataSubscription()
        registerTableViewCell()
        //TODO: Data binding (no creo que haga falta)
    }
    
    private func loadItemDataSubscription(){
        viewModel.itemDetails.subscribe { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadUIData()
            }
        }.disposed(by: disposeBag)
    }
    
    private func loadUIData(){
        itemTitle.text = viewModel.getItemTitle()
        itemImagesURL = viewModel.getItemPicturesUrl()
        imageCarousel.reloadSections(IndexSet(integer: 0))//.reloadData() flickering
        itemPrice.text = viewModel.getItemPrice()
        itemWarranty.text = viewModel.getItemWarranty()
        conditionAndSoldQuantity.text = viewModel.getItemConditionAndSoldQuatity()
        sellerAddress.text = viewModel.getItemSellerAddress()
        itemAttributes = viewModel.getItemAttributes()
        itemAttributesTable.reloadData()
    }
    
    private func registerTableViewCell(){
        itemAttributesTable.register(UINib.init(nibName: Constants.Identifiers.ITEM_ATTRIBUTES_VIEW_CELL, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.ITEM_ATTRIBUTES_VIEW_CELL)
    }
    @IBAction func permalinkButtonAction(_ sender: Any) {
        viewModel.openPermalinkToItem()
    }
    
}

extension ItemDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemImagesURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.IMAGES_CAROUSEL_VIEW_CELL, for: indexPath) as? ItemImagesCollectionViewCell {
            cell.thumbnailImageView.getImageFromURL(imageURLString: itemImagesURL[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
}

extension ItemDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemAttributes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemAttributesTableViewCell") as? ItemAttributesTableViewCell else {
            return UITableViewCell()
        }
        let attributeKey = itemAttributes[indexPath.row].name
        let attributeValue = itemAttributes[indexPath.row].valueName!
        cell.configureCell(with:attributeKey, value: attributeValue, oddStyle: (indexPath.row % 2 == 0))
        
        return cell
    }
    
    
}
