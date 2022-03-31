//
//  UIImageView+URLSession.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import UIKit

extension UIImageView {
    
    func getImageFromURL(imageURLString: String) {
                
        if self.image == nil {
            self.image = Constants.Images.placeholderImage
        }
        //TODO: Add image caching with NSCache or NSURLCache
        guard let url = URL(string: imageURLString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                print("UIImageView+URLSession - func getImageFromURL(imageURLString:) Error: \(error.debugDescription)")
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data else { return }
                let image = UIImage(data: data)
                self.image = image
            }
        }.resume()
    }
}
