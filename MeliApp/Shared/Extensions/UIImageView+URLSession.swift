//
//  UIImageView+URLSession.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import UIKit

extension UIImageView {
    
    func getImageFromURL(imageURLString: String) {
        //Set a placeholder image if nil
        if self.image == nil {
            self.image = Constants.Images.placeholderImage
        }
        
        guard let url = URL(string: imageURLString) else { return }
        let request = URLRequest(url: url)
        //Attempt to read from cache
        let imagesCache = Constants.Images.cache
        if let cachedResponse = imagesCache.cachedResponse(for: request) {
            if let cachedImage = UIImage(data: cachedResponse.data) {
                DispatchQueue.main.async {
                    self.image = cachedImage
                }
                return
            }
        }
        //Perform image download
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                Log.event(type: .error, "Failed to download image, reason: \(error.debugDescription)")
                return
            }
            
            DispatchQueue.main.async {
                guard let data = data else { return }
                //Store image data in cache
                let cachedData = CachedURLResponse(response: response!, data: data)
                imagesCache.storeCachedResponse(cachedData, for: request)
                let image = UIImage(data: data)
                self.image = image
            }
        }.resume()
    }
}
