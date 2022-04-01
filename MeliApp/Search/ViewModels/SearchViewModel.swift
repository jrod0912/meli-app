//
//  SearchViewModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation
import RxSwift

class SearchViewModel {
    //Inputs:
    private var provider:SearchProviderProtocol!
    //Sub-viewmodel source
    private var tableDataSource:[SearchResultViewModel] = []
    //Outputs:
    var numberOfRows:Int = 0
    //Observers inputs
    var searchResults = PublishSubject<[SearchResult]>()
    var cellSelected = PublishSubject<SearchResultViewModel>()
    var reloadTableData = PublishSubject<Bool>()
    var showLoadingSubject = PublishSubject<Bool>()
    var showErrorSubject = PublishSubject<String>() //TODO: Cambiar String por Error
    var cancelButtonTapped = PublishSubject<Void>()
    var selectedItemId = PublishSubject<IndexPath>()
    var searchQuery = PublishSubject<String>()
    private var disposeBag = DisposeBag()
    
        
    init(provider: SearchProviderProtocol = SearchProvider()) {
        self.provider = provider
        initialize()
    }
    
    func initialize() {
        searchQuery
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMapLatest { query -> Observable<[SearchResult]> in
                //Always clear previous searchs
                self.resetTableDataSource()
                //Init loading animation
                self.showLoadingSubject.onNext(true)

                return self.searchItemsForTerm(q: query)
                    .catch { error -> Observable<[SearchResult]> in
                        self.showErrorSubject.onNext(error.localizedDescription)
                        return Observable.empty()
                    }
            }.subscribe(onNext: { results in
                //Hide loading animation
                self.showLoadingSubject.onNext(false)
                
                if results.isEmpty {
                    self.showErrorSubject.onNext("Some Error") //TODO: Cambiar String por Error
                } else {
                    self.prepareTableDataSource(results: results)
                    self.reloadTableData.onNext(true)
                }
            })
            .disposed(by: disposeBag)
        
        
        cancelButtonTapped
            .asObservable()
            .subscribe(onNext: { [self] _ in
                resetTableDataSource()
                reloadTableData.onNext(true)
            }).disposed(by: disposeBag)
        
        selectedItemId
            .asObservable()
            .map({ [self] indexPath in
                cellSelected(indexPathRow: indexPath.row)
            })
            .subscribe(onNext: { [self] selected in
                cellSelected.onNext(selected)
            }).disposed(by: disposeBag)
    }
    
    func prepareTableDataSource(results: [SearchResult]) {
        numberOfRows = results.count
        tableDataSource = results.map({ SearchResultViewModel(searchResultModel: $0) })
    }
    
    func searchItemsForTerm(q: String) -> Observable<[SearchResult]> {
        return Observable.create({ [self] (observer) -> Disposable in
            provider.getSearchResultsFor(query: q) { result in
                switch result {
                    case .success(let searchModel):
                        if searchModel.results.isEmpty {
                            observer.onError(CustomError.search(type: .notFound))
                        }else{
                            observer.onNext(searchModel.results)
                            observer.onCompleted()
                        }
                    case .failure(let error):
                        observer.onError(error)
                    }
            }
            return Disposables.create()
        })
    }
    
    func getViewModelForCell(indexPathRow: Int) -> SearchResultViewModel {
        return tableDataSource[indexPathRow]
    }
    
    //TODO: Revisar si debería pasar todo el viemodel a pesar de que no es compatible con la vista de detalle y en aquella vista para generar el viewmodel solo necesito el id (String)
    func cellSelected(indexPathRow: Int) -> SearchResultViewModel {
        return tableDataSource[indexPathRow]
    }
    
    private func resetTableDataSource() {
        numberOfRows = 0
        tableDataSource = []
    }
}


struct SearchResultViewModel {
    
    //Input: el data model de resultados de busqueda
    var searchResult:SearchResult!
    //Outputs: Data procesada para alimentar la celda de la tabla
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
        return "en \(installments.quantity)x $ \(installments.amount)"
    }
    
    private func getItemFreeShipping() -> String {
        return (searchResult.shipping.freeShipping) ? "Envío Gratuito" : ""
    }
    
    private func getItemThumbnailUrl() -> String {
        return searchResult.thumbnail
    }
}

