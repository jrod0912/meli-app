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
    private var errorView = ErrorView()
    private var loadingView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setNavigationBarImageView()
        setupLoadingView()
        setupSubscriptions()
        setupTableView()
        configureSearchBarController()
        bindSearchData()
    }
    
    func setNavigationBarImageView() {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        imageView.image = UIImage(named: "navigation")
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    func setupLoadingView() {
        loadingView = UIActivityIndicatorView(frame: self.view.frame)
        loadingView.style = .large
        loadingView.color = .systemBlue
        loadingView.center = self.view.center
        loadingView.backgroundColor = .white
        self.view.addSubview(loadingView)
    }
    
    func setupSubscriptions(){
        showErrorSubscription()
        showLoadingViewSubscription()
        reloadDataSubscription()
        selectedItemSubscription()
    }
    
    func setupTableView() {
        searchItemsTableView.backgroundView = errorView
        searchItemsTableView.rowHeight = UITableView.automaticDimension
        registerTableViewCell()
    }
    
    func configureSearchBarController(){
        searchBarController.searchBar.searchTextField.backgroundColor = .white
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
    
    private func navigateToItemDetailsWithSearchResult(_ searchResultVM: SearchResultViewModel) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: Constants.Identifiers.ITEM_DETAILS_VIEW_CONTROLLER) as? ItemDetailsViewController else {
            return
        }
        controller.prepareView(itemId: searchResultVM.id)
        navigationController?.pushViewController(controller, animated: true)
    }
        
}
//MARK: - Table view delegate and dataSource implementations
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.SEARCH_ITEM_VIEW_CELL) as? SearchItemViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(viewModel: viewModel.getViewModelForCell(indexPathRow: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
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

//MARK: Reactive stuff

extension SearchViewController {
    
    private func showLoadingViewSubscription() {
        viewModel.showLoadingSubject.debug().subscribe(onNext:{ [weak self] show in
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + ((show) ? 0.0 : 1.5)) {
                (show) ? self.loadingView.startAnimating() : self.loadingView.stopAnimating()
            }
        }).disposed(by: disposeBag)
    }

    private func showErrorSubscription() {
        viewModel.showErrorSubject.debug().subscribe(onNext:{ [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + ((error) ? 1.5 : 0.0)) {
                (!error) ? self.errorView.fadeOut() : self.errorView.fadeIn()
            }
        }).disposed(by: disposeBag)
    }
    
    private func reloadDataSubscription(){
        viewModel.reloadTableData.debug().subscribe { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.searchItemsTableView.reloadData()
            }
        }.disposed(by: disposeBag)
    }
    
    private func selectedItemSubscription(){
        viewModel.cellSelected.debug().subscribe { [weak self] event in
            guard let self = self else { return }
            guard let selected = event.element else { return }
            DispatchQueue.main.async{
                self.navigateToItemDetailsWithSearchResult(selected)
            }
        }.disposed(by: disposeBag)
    }
    
    private func bindSearchData (){
        
        searchBarController.searchBar.rx
            .cancelButtonClicked
            .bind(to: viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
        
        searchBarController.searchBar.rx
            .searchButtonClicked
            .withLatestFrom(searchBarController.searchBar.rx.text.orEmpty)
            .bind(to: viewModel.searchQuery)
            .disposed(by: disposeBag)
        
        searchItemsTableView.rx
            .itemSelected
            .bind(to: viewModel.selectedItemId)
            .disposed(by: disposeBag)
    }
}
