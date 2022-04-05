//
//  SearchProviderTests.swift
//  MeliAppTests
//
//  Created by Jorge Rodríguez on 5/04/22.
//

import XCTest
@testable import MeliApp

class SearchProviderTests: XCTestCase {
    
    var sut: SearchProviderProtocol!
    var tSearchModel: SearchModel!
    
    override func setUp() {
        super.setUp()
        sut = MockSearchProvider(jsonFileName: "searchWithResults")
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
        tSearchModel = nil
    }
    
    func test_getItemsForSearchTermWithResultsAndZeroOffset() {
        let tQuery = "Mac Mini"
        let tOffset = 0
        tSearchModel = getSingleResultSearchModel()
        
        sut.getSearchResultsFor(query: tQuery, with: tOffset) { result in
            switch result {
            case .success(let model):
                XCTAssertEqual(model, self.tSearchModel, "Parsed Search model")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func test_getItemsForSearchTermWithNoResultsAndZeroOffset() {
        
        let tQuery = "a"
        let tOffset = 0
        tSearchModel = getZeroResultsSearchModel()
        sut = MockSearchProvider(jsonFileName: "searchWithNoResults")
        sut.getSearchResultsFor(query:tQuery, with: tOffset) { result in
            switch result {
            case .success(let model):
                XCTAssertTrue(model.results.isEmpty, "SearchModel has no [SearchResult]")
            case .failure(let error):
                XCTFail("SearchItem with empty results shouldn't cause error in result  \(error.localizedDescription)")
            }
        }
    }
    
    func getZeroResultsSearchModel() -> SearchModel {
        let tQuery = "a"
        let searchPaging = SearchPaging(total: 0, offset: 0, limit: 50)
        return SearchModel(query: tQuery, results: [], paging: searchPaging)
    }
    
    func getSingleResultSearchModel() -> SearchModel {
        let searchResultShipping = SearchResultShipping(freeShipping: true)
        let searchResultInstallments = SearchResultInstallment(quantity: 36,
                                                                amount: 138611.11,
                                                                rate: 0)
        let searchPaging = SearchPaging(total: 98, offset: 0, limit: 1)
        let searchResults = SearchResult(id: "MCO602661276",
                                          title: "Apple Mac Mini M1 (2020) 8 Core 256 Gb  16gb Ram",
                                         price: 4990000,
                                          condition: "new",
                                          thumbnail: "http://http2.mlstatic.com/D_991158-MCO44638673412_012021-O.jpg",
                                          installments: searchResultInstallments,
                                          shipping: searchResultShipping)

        let searchModel = SearchModel(query: "Mac Mini",
                                      results: [searchResults],
                                      paging: searchPaging)
        return searchModel
    }
    
}
