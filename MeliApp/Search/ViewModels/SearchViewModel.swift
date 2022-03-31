//
//  SearchViewModel.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import Foundation
import RxSwift
import UIKit

struct SearchViewModel {
    
    private var provider:SearchProviderProtocol!
    private var disposeBag = DisposeBag()
    
    var searchResults = PublishSubject<[SearchResult]>()
    var results:[SearchResult] = []
    var showLoadingSubject = PublishSubject<Bool>()
    var showErrorSubject = PublishSubject<String>()
    var cancelButtonTapped = PublishSubject<Void>()
    var selectedItemId = PublishSubject<IndexPath>()
    
    private let searchQuerySubject = PublishSubject<String>()
    var searchQueryObserver: AnyObserver<String> {
        return searchQuerySubject.asObserver()
    }
    
    init(provider: SearchProviderProtocol = SearchProvider()) {
        self.provider = provider
        initialize()
        //subscribeToSelectedItem()
    }
    
    func initialize() {
        
        searchQuerySubject
            .asObservable()
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .debug()
            .debounce(DispatchTimeInterval.seconds(3), scheduler: MainScheduler.instance)
            .flatMapLatest { query -> Observable<[SearchResult]> in
                self.showErrorSubject.onNext("Reset search...")
                self.showLoadingSubject.onNext(true)
                return self.searchItemsForTerm(q: query)
                    .catch { error -> Observable<[SearchResult]> in
                        self.showErrorSubject.onNext(error.localizedDescription)
                        return Observable.empty()
                    }
            }
            .subscribe(onNext: { elements in
                self.showLoadingSubject.onNext(false)
                if elements.isEmpty {
                    self.showErrorSubject.onNext("No data found")
                } else {
                    self.searchResults.onNext(elements)
                }
            })
            .disposed(by: disposeBag)
    }
    
//    func subscribeToSelectedItem() {
//        selectedItemId
//            .asObservable()
//            .flatMapLatest { index -> Observable<IndexPath> in
//                return self.getSelectedItem(at: index.row)
//            }
//            .subscribe(onNext: { index in
//                self.selectedItemId.onNext(index)
//                self.selectedItemId.onCompleted()
//            })
//            
//    }
    
    func searchItemsForTerm(q: String) -> Observable<[SearchResult]> {
        
        return Observable.create({ (observer) -> Disposable in
            
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
    
    func getItemTitle(at index: Int) -> String {
        return results[index].title
    }
    
    func getItemPrice(at index: Int) -> String {
        return NumberFormatter.currencyFormatter.string(from: results[index].price as NSNumber)!
    }
    
    func getItemInstallments(at index: Int) -> String {
        return "en \(results[index].installments.quantity)x $ \(results[index].installments.amount)"
    }
    
    func getItemFreeShipping(at index: Int) -> String {
        return (results[index].shipping.freeShipping) ? "Envío Gratuito" : ""
    }
    
    func getItemThumbnailUrl(at index: Int) -> String {
        return results[index].thumbnail
    }
    
//    func getSelectedItem(at index: Int) -> Observable<IndexPath> {
//        return Observable.create { (observer) -> Disposable in
//            observer.onNext([index])
//            observer.onCompleted()
//        }
//    }
    
    func getSelectedItemId(at index: Int) -> String {
        return results[index].id
    }
    
    //TODO: Debería utilizar un viewmodel solo para las celdas de resultados ???
    /*func viewModelForCell(at index: Int) -> SearchResultViewModel {
        return SearchResultViewModel(searchResult: searchResults.[index])
    }*/
    
    
}

/* //TODO: si decido utilizar el viewmodel solo para las celdas
struct SearchResultViewModel {
    
    private var searchResult:SearchResult!
    
    init(searchResult: SearchResult) {
        
    }
    
}
*/
