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
    //Pagination
    private var currentSearchOffset = 0
    private var currentSearchQuery = ""
    //Outputs:
    var numberOfRows:Int = 0
    var hasMoreSearchResults = false
    //Observers inputs
    var searchResults = PublishSubject<[SearchResult]>()
    var cellSelected = PublishSubject<SearchResultViewModel>()
    var reloadTableData = PublishSubject<Bool>()
    var showLoadingSubject = PublishSubject<Bool>()
    var showErrorSubject = PublishSubject<Bool>()
    var cancelButtonTapped = PublishSubject<Void>()
    var selectedItemId = PublishSubject<IndexPath>()
    var searchQuery = PublishSubject<String>()
    var canFetchMoreData = PublishSubject<Void>()
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
                Log.event(type: .info, "User started search for: \(query)")
                self.currentSearchQuery = query
                //Always clear previous searchs if there's a new search term
                self.resetTableDataSource()
                //Init loading animation
                self.showErrorSubject.onNext(false)
                self.showLoadingSubject.onNext(true)
                
                return self.searchItemsForTerm()
                    .catch { error -> Observable<[SearchResult]> in
                        self.showLoadingSubject.onNext(false)
                        self.showErrorSubject.onNext(true)
                        self.reloadTableData.onNext(true)
                        return Observable.empty()
                    }
            }.subscribe(onNext: { results in
                //Hide loading animation
                self.showLoadingSubject.onNext(false)
                
                if results.isEmpty {
                    self.showErrorSubject.onNext(true)
                    self.reloadTableData.onNext(true)
                } else {
                    self.prefetchImages()
                    self.showErrorSubject.onNext(false)
                    self.prepareTableDataSource(results: results)
                    self.reloadTableData.onNext(true)
                }
            })
            .disposed(by: disposeBag)
        
        cancelButtonTapped
            .asObservable()
            .subscribe(onNext: { [self] _ in
                showErrorSubject.onNext(false)
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
        
        canFetchMoreData
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMapLatest { _ -> Observable<[SearchResult]> in
                Log.event(type: .info, "User reached end of table search results, fetch next \(self.currentSearchOffset) results")
                return self.searchItemsForTerm()
                    .catch { error -> Observable<[SearchResult]> in
                        Log.event(type: .error, "Failed to fetch next \(self.currentSearchOffset) results")
                        return Observable.empty()
                    }
            }.subscribe(onNext: { results in
                self.prefetchImages()
                self.prepareTableDataSource(results: results)
                self.reloadTableData.onNext(true)
            })
            .disposed(by: disposeBag)
        
    }
    
    func updateCurrentOffset(paging: SearchPaging){
        let nextOffset = currentSearchOffset + 50
        hasMoreSearchResults = (paging.total > nextOffset)
        if hasMoreSearchResults {
            currentSearchOffset = nextOffset
        }
    }
    
    func prepareTableDataSource(results: [SearchResult]) {
        numberOfRows = numberOfRows + results.count
        let preparedData = results.map({ SearchResultViewModel(searchResultModel: $0) })
        tableDataSource.append(contentsOf: preparedData)
    }
    
    func searchItemsForTerm() -> Observable<[SearchResult]> {
        return Observable.create({ [self] (observer) -> Disposable in
            provider.getSearchResultsFor(query: currentSearchQuery, with: currentSearchOffset) { result in
                switch result {
                    case .success(let searchModel):
                        if searchModel.results.isEmpty {
                            Log.event(type: .error, "Search didn't return any results!")
                            observer.onError(CustomError.search(type: .notFound))
                        }else{
                            self.updateCurrentOffset(paging: searchModel.paging)
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
    
    func cellSelected(indexPathRow: Int) -> SearchResultViewModel {
        Log.event(type: .info, "User selected item: \(tableDataSource[indexPathRow])")
        return tableDataSource[indexPathRow]
    }
    
    private func resetTableDataSource() {
        Log.event(type: .info, "User tap cancel button, clear search data")
        numberOfRows = 0
        tableDataSource = []
        currentSearchOffset = 0
    }
    
    private func prefetchImages() {
        DispatchQueue.main.async { [self] in
            _ = tableDataSource.map { UIImageView().getImageFromURL(imageURLString: $0.thumbnailUrl) }
        }
    }
}
