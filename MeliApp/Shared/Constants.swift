//
//  Constants.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 28/03/22.
//

import Foundation
import UIKit

struct Constants {
    
    static let userDefaults = UserDefaults.standard
    
    struct Identifiers {
        static let SEARCH_ITEM_VIEW_CELL = "SearchItemViewCell"
        static let IMAGES_CAROUSEL_VIEW_CELL = "imageCarouselCell"
        static let ITEM_ATTRIBUTES_VIEW_CELL = "ItemAttributesTableViewCell"
        static let ITEM_DETAILS_VIEW_CONTROLLER = "ItemDetailsViewController"
    }
    
    struct PlaceholderText {
        static let SEARCH_BAR_PLACEHOLDER = "Buscar en Mercado Libre..."
        static let INSTALLMENTS_PLACEHOLDER = "en {cantidad_cuotas}x {monto_cuotas}"
        static let FREE_SHIPPING_PLACEHOLDER = "Envío Gratuito"
    }
    
    struct Images {
        static let placeholderImage: UIImage = UIImage(systemName: "photo.on.rectangle.angled")!
        static let unlikeImage: UIImage = UIImage(systemName: "heart")!
        static let likeImage: UIImage = UIImage(systemName: "heart.fill")!
        static let cache = URLCache.shared
    }
}
