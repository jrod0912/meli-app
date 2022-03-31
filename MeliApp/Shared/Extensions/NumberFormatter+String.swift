//
//  NumberFormatter+String.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 29/03/22.
//

import Foundation

extension NumberFormatter {
    static var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_CO")
        return formatter
    }
}
