//
//  ItemProviderTests.swift
//  MeliAppTests
//
//  Created by Jorge Rodríguez on 5/04/22.
//

import XCTest

@testable import MeliApp

class ItemProviderTests: XCTestCase {
    var sut: ItemProviderProtocol!
    var tItemModel: ItemModel!
    
    override func setUp() {
        sut = MockItemProvider(jsonFileName: "itemDetails")
        tItemModel = getSampleItemModel()
    }
    
    override func tearDown() {
        sut = nil
        tItemModel = nil
        super.tearDown()
    }
    
    func test_getItemByIdPicturesResultSuccess() {
        let tItemId = "MCO599428039"
        sut.getItemById(itemId: tItemId) { result in
            switch result {
            case .success(let model):
                XCTAssertEqual(model.pictures, self.tItemModel.pictures)
            case .failure(let error):
                XCTFail("Should not return error for valid tItemId, reason: \(error.localizedDescription)")
            }
        }
    }
    
    func test_getItemByIdSellerAddressResultSuccess() {
        let tItemId = "MCO599428039"
        sut.getItemById(itemId: tItemId) { result in
            switch result {
            case .success(let model):
                XCTAssertEqual(model.sellerAddress, self.tItemModel.sellerAddress)
            case .failure(let error):
                XCTFail("Should not return error for valid tItemId, reason: \(error.localizedDescription)")
            }
        }
    }
    
    func test_getItemByIdAttributesResultSuccess() {
        let tItemId = "MCO599428039"
        sut.getItemById(itemId: tItemId) { result in
            switch result {
            case .success(let model):
                XCTAssertEqual(model.attributes, self.tItemModel.attributes)
            case .failure(let error):
                XCTFail("Should not return error for valid tItemId, reason: \(error.localizedDescription)")
            }
        }
    }
    
    func test_getItemByIdReturnsResultSuccess() {
        let tItemId = "MCO599428039"
        sut.getItemById(itemId: tItemId) { result in
            switch result {
            case .success(let model):
                XCTAssertEqual(model, self.tItemModel)
            case .failure(let error):
                XCTFail("Should not return error for valid tItemId, reason: \(error.localizedDescription)")
            }
        }
    }
    
    func test_getItemByIdReturnsErrorForItemNotFound() {
        let tItemId = "MLA599428031"
        sut = MockItemProvider(jsonFileName: "itemNotFound")
        sut.getItemById(itemId: tItemId) { result in
            switch result {
            case .success( _ ):
                XCTFail("Should not return success for not existing item")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        }
    }
    
    func test_getItemByIdReturnsErrorForBadRequest() {
        let tItemId = "MOC000000"
        sut = MockItemProvider(jsonFileName: "badRequestItemId")
        sut.getItemById(itemId: tItemId) { result in
            switch result {
            case .success( _ ):
                XCTFail("Should not return success for not existing item")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        }
    }
    
    func test_getItemByIdReturnsErrorForResourceNotFound() {
        let tItemId = "MCO"
        sut = MockItemProvider(jsonFileName: "resourceNotFound")
        sut.getItemById(itemId: tItemId) { result in
            switch result {
            case .success( _ ):
                XCTFail("Should not return success for not existing item")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        }
    }
    
    func getSampleItemModel() -> ItemModel {
        
        let tItemPictures = getItemPictures()
        let tItemSellerAddress = getItemSellerAddress()
        let tItemAttributes = getItemAttributes()
        
        let itemModel = ItemModel(id: "MCO599428039",
                               title: "Nueva Mac Mini M1 (2020) 8 Core Cpu-gpu - 512 Gb - 8gb Ram",
                               sellerId: 22831793,
                               price: 4686594,
                               initialQuantity: 51,
                               availableQuantity: 1,
                               soldQuantity: 1,
                               condition: "new",
                               permalink: "https://articulo.mercadolibre.com.co/MCO-599428039-nueva-mac-mini-m1-2020-8-core-cpu-gpu-512-gb-8gb-ram-_JM",
                               pictures: tItemPictures,
                               shipping: ItemShipping.init(freeShipping: true),
                               sellerAddress: tItemSellerAddress,
                               attributes: tItemAttributes,
                               warranty: "Garantía de fábrica: 12 meses")
        return itemModel
    }
    
    func getItemPictures() -> [ItemPicture]{
        let tItemPictures = [
            ItemPicture(id: "629989-MCO48524283498_122021", secureURL: "https://http2.mlstatic.com/D_629989-MCO48524283498_122021-O.jpg"),
            ItemPicture(id: "621291-MCO44244032465_122020", secureURL: "https://http2.mlstatic.com/D_621291-MCO44244032465_122020-O.jpg"),
            ItemPicture(id: "769681-MCO44244032632_122020", secureURL: "https://http2.mlstatic.com/D_769681-MCO44244032632_122020-O.jpg"),
            ItemPicture(id: "892560-MCO44244034605_122020", secureURL: "https://http2.mlstatic.com/D_892560-MCO44244034605_122020-O.jpg"),
            ItemPicture(id: "789621-MCO44244034636_122020", secureURL: "https://http2.mlstatic.com/D_789621-MCO44244034636_122020-O.jpg"),
            ItemPicture(id: "648565-MCO44244048048_122020", secureURL: "https://http2.mlstatic.com/D_648565-MCO44244048048_122020-O.jpg"),
            ItemPicture(id: "716100-MCO44244032690_122020", secureURL: "https://http2.mlstatic.com/D_716100-MCO44244032690_122020-O.jpg"),
            ItemPicture(id: "895314-MCO44244038462_122020", secureURL: "https://http2.mlstatic.com/D_895314-MCO44244038462_122020-O.jpg")
        ]
        return tItemPictures
    }
    
    func getItemSellerAddress() -> ItemSellerAddress  {
        let tItemSellerAddress = ItemSellerAddress(
            city: ItemAddressCity(id: "TUNPQ0NBTDYyZDA0", name: "Cali"),
            state: ItemAddressCity(id: "CO-VAC", name: "Valle Del Cauca")
        )
        return tItemSellerAddress
    }
    
    func getItemAttributes() -> [ItemAttribute] {
        let tItemAttributes = [
            ItemAttribute(id: "BRAND", name: "Marca", valueName: "Apple"),
            ItemAttribute(id: "CONNECTIVITY", name: "Conectividad", valueName: "WIFI 6,Thunderbolt,HDMI,Ethernet"),
            ItemAttribute(id: "ITEM_CONDITION", name: "Condición del ítem", valueName: "Nuevo"),
            ItemAttribute(id: "LINE", name: "Línea", valueName: "Mac Mini"),
            ItemAttribute(id: "MODEL", name: "Modelo", valueName: "Mac Mini 3.1 GHz"),
            ItemAttribute(id: "OS_NAME", name: "Nombre del sistema operativo", valueName: "macOS"),
            ItemAttribute(id: "OS_VERSION", name: "Versión del sistema operativo", valueName: "MacOS Big Sur"),
            ItemAttribute(id: "PROCESSOR", name: "Procesador", valueName: "M1"),
            ItemAttribute(id: "RAM_MEMORY", name: "Memoria RAM", valueName: "8 GB"),
            ItemAttribute(id: "STORAGE_CAPACITY", name: "Capacidad de almacenamiento", valueName: "512 GB"),
            ItemAttribute(id: "VIDEO_PORTS", name: "Puertos de video", valueName: "HDMI"),
            ItemAttribute(id: "VOLTAGE", name: "Voltaje", valueName: nil)
        ]
        return tItemAttributes
    }
}
