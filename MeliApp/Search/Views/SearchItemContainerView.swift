//
//  SearchItemContainerView.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 28/03/22.
//

import UIKit

@IBDesignable class SearchItemContainerView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
}
