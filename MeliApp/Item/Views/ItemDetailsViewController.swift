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
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var likeButton: UIBarButtonItem!
    
    private var disposeBag = DisposeBag()
    private var viewModel = ItemViewModel()
    private var loadingView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Suscriptions (falta like)
        setupLoadingView()
        registerTableViewCell()
        bindData()
        self.likeButton.image =  Constants.Images.unlikeImage
    }
    
    func prepareView(itemId: String) {
        setupSubscriptions()
        viewModel.selectedItemIdSubject.onNext(itemId)
    }
    
    func setupLoadingView() {
        loadingView = UIActivityIndicatorView(frame: self.view.frame)
        loadingView.style = .large
        loadingView.color = .systemBlue
        loadingView.center = self.view.center
        loadingView.backgroundColor = .white
        self.view.addSubview(loadingView)
    }
    
    private func loadUIData(){
        itemTitle.text = viewModel.title
        itemPrice.text = viewModel.price
        itemWarranty.text = viewModel.warranty
        conditionAndSoldQuantity.text = viewModel.conditionAndSoldQty
        sellerAddress.text = viewModel.sellerAddress
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
        return viewModel.numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Identifiers.IMAGES_CAROUSEL_VIEW_CELL, for: indexPath) as? ItemImagesCollectionViewCell {
            let imageUrl = viewModel.getImageUrlForCell(indexPathRow: indexPath.row)
            cell.thumbnailImageView.getImageFromURL(imageURLString: imageUrl)
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ItemDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfAttributes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.ITEM_ATTRIBUTES_VIEW_CELL) as? ItemAttributesTableViewCell else {
            return UITableViewCell()
        }
        let vm = viewModel.getViewModelForCell(indexPathRow: indexPath.row)
        cell.configureCell(with:vm.attributeKey, value: vm.attributeValue, oddStyle: (indexPath.row % 2 == 0))
        return cell
    }
}

//MARK: Reactive stuff

extension ItemDetailsViewController {
    
    private func setupSubscriptions(){
        showLoadingViewSubscription()
        loadItemDataSubscription()
        loadItemDescriptionSubscription()
        likeItemSubscription()
    }
    
    private func loadItemDataSubscription(){
        viewModel.loadItemData.subscribe { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadUIData()
                self.itemAttributesTable.reloadData()
                self.imageCarousel.reloadSections(IndexSet(integer: 0))
            }
        }.disposed(by: disposeBag)
    }
    
    private func loadItemDescriptionSubscription(){
        viewModel.loadItemDescription.subscribe { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.itemDescription.text = self.viewModel.description
            }
        }.disposed(by: disposeBag)
    }
    
    private func showLoadingViewSubscription() {
        viewModel.showLoadingSubject.subscribe(onNext:{ [weak self] show in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + ((show) ? 0.0 : 1.5)) {
                (show) ? self.loadingView.startAnimating() : self.loadingView.stopAnimating()
            }
        }).disposed(by: disposeBag)
    }
    
    private func likeItemSubscription() {
        viewModel.showLikedSubject.subscribe(onNext:{ [weak self] liked in
            guard let self = self else { return }
            DispatchQueue.main.async{
                self.likeButton.image = (liked) ? Constants.Images.likeImage : Constants.Images.unlikeImage
            }
        }).disposed(by: disposeBag)
    }

    private func bindData(){
        likeButton.rx.tap
            .bind(to: viewModel.likeItemSubject)
            .disposed(by: disposeBag)
    }

}
