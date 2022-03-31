//
//  SearchViewController.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {

    @IBOutlet weak var searchItemsTableView: UITableView!
    
    private var searchBarController = UISearchController()
    private var disposeBag = DisposeBag()
    private var viewModel = SearchViewModel()
    private var tableDataSource:[SearchResult] = []
    private var isPaginating = false
    private var selectedItem = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        imageView.image = UIImage(named: "navigation")
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        setupSubscriptions()
        setupTableView()
        configureSearchBarController()
        bindSearchData()
    }
    
    func setupSubscriptions(){
        showErrorSubscription()
        showLoadingViewSubscription()
        reloadDataSubscription()
        clearTableSubscription()
        //selectedItemSubscription()
    }
    
    func setupTableView() {
        let errorLabel = UILabel()
        errorLabel.text = "AAAAAAAAAAAAAAAAAAAAAAAAAAHHHHH!!!!!!"
        searchItemsTableView.backgroundView = errorLabel
        searchItemsTableView.rowHeight = UITableView.automaticDimension
        registerTableViewCell()
    }
    
    func configureSearchBarController(){
        searchBarController.searchBar.searchTextField.backgroundColor = .white
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.placeholder = Constants.PlaceholderText.SEARCH_BAR_PLACEHOLDER
        navigationItem.searchController = searchBarController
    }
    
    private func registerTableViewCell(){
        searchItemsTableView.register(UINib.init(nibName: Constants.Identifiers.SEARCH_ITEM_VIEW_CELL, bundle: nil), forCellReuseIdentifier: Constants.Identifiers.SEARCH_ITEM_VIEW_CELL)
    }
    
    func createAndDisplayLoadingView() -> UIView {
        let loaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.center = loaderView.center
        loaderView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        return loaderView
    }
    
    //TODO: De esto deberia encargarse el VM o es legal hacerlo asi?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemDetails" {
            let detailVC = segue.destination as! ItemDetailsViewController
            detailVC.selectedItemId = selectedItem
        }
    }
    
}
//MARK: - Table view delegate and dataSource implementations
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.SEARCH_ITEM_VIEW_CELL) as? SearchItemViewCell else {
            return UITableViewCell()
        }
        // Mover esto a un vm solo para celda?
        cell.itemImageView.getImageFromURL(imageURLString: viewModel.getItemThumbnailUrl(at: indexPath.row))
        cell.itemTitle.text = viewModel.getItemTitle(at: indexPath.row)
        cell.itemPrice.text = viewModel.getItemPrice(at: indexPath.row)
        cell.itemInstallments.text = viewModel.getItemInstallments(at: indexPath.row)
        cell.itemHasFreeShipping.text = viewModel.getItemFreeShipping(at: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: De esto deberia encargarse el VM o es legal hacerlo asi?
        selectedItem = tableDataSource[indexPath.row].id
        self.performSegue(withIdentifier: "showItemDetails", sender: nil)
    }
    
    //TODO: Pedir data paginada
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let scrollPosition = scrollView.contentOffset.y
//        let scrollViewHeight = scrollView.frame.size.height
//        let tableOffset = searchItemsTableView.contentSize.height
//        let totalOffset = (tableOffset - 100 - scrollViewHeight)
//        let paginationFactor = (scrollPosition - totalOffset)
//
//        if paginationFactor > 160 {
//            if !isPaginating {
//                self.searchItemsTableView.tableFooterView = createAndDisplayLoadingView()
//                isPaginating = true
//
//                //Only add rows if there are less than 50
//                if count < 15 {
//                    count+=3
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
//                        print("count \(self.count)")
//                        self.searchItemsTableView.tableFooterView = nil
//                        self.searchItemsTableView.reloadData()
//                        isPaginating = false
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        self.searchItemsTableView.tableFooterView = nil
//                        self.isPaginating = false
//                    }
//                }
//            }
//        }
//    }
    
}

extension SearchViewController: UISearchBarDelegate {
    //TODO: Realizar la busqueda se inicie con este evento en vez de con el type del campo
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        print("Search for: \(searchTerm)")
    }
}

extension SearchViewController {
    
    private func showLoadingViewSubscription() {
        //TODO: Agregar animacion o vista de carga
        viewModel.showLoadingSubject.debug().subscribe(onNext:{ /*[weak self]*/ show in
            //guard let self = self else { return }
            if show { print("App is searching...") } else {print("Search has finished...")}
        }).disposed(by: disposeBag)
    }

    private func showErrorSubscription() {
        //TODO: Agregar vista de error o modal
        viewModel.showErrorSubject.debug().subscribe(onNext:{ [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableDataSource = []
                self.searchItemsTableView.reloadData()
            }
            
            print("An error has occured: \(error)")
            
            
            //self.tableDataSource = []
        }).disposed(by: disposeBag)
    }
    
    private func clearTableSubscription() {
        viewModel.cancelButtonTapped.debug().subscribe(onNext:{ [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableDataSource = []
                self.searchItemsTableView.reloadData()
            }
        }).disposed(by: disposeBag)
    }
    
    private func reloadDataSubscription(){
        viewModel.searchResults.debug().subscribe { [weak self] e in
            guard let self = self else { return }
            guard let searchResults = e.element else { return }
            
            DispatchQueue.main.async {
                self.viewModel.results = searchResults
                self.tableDataSource = searchResults
                self.searchItemsTableView.reloadData()
            }
            
            for result in searchResults {
                print("result: \(result) \n\n")
            }
            
        }.disposed(by: disposeBag)
    }
    
    private func selectedItemSubscription(){
//        viewModel.selectedItemId.debug().subscribe { _ in DispatchQueue.main.async{
//            performSegue(withIdentifier: "showItemDetails", sender: self)
//            }
//        }.disposed(by: disposeBag)
    }
    
    private func bindSearchData (){
        
        searchBarController.searchBar.rx
            .cancelButtonClicked
            .debug()
            .bind(to: viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
        
        searchBarController.searchBar.rx
            .text
            .orEmpty
            .distinctUntilChanged()
            .debug()
            .bind(to: viewModel.searchQueryObserver)
            .disposed(by: disposeBag)
        
        searchItemsTableView.rx
            .itemSelected
            .debug()
            .bind(to: viewModel.selectedItemId)
            .disposed(by: disposeBag)
    }
}
