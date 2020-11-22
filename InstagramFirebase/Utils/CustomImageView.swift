//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by Григорий on 22.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        print("Loading image...")
        
        lastURLUsedToLoadImage = urlString
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            if let err = err {
                print("Failed to fetch post image", err)
                return
            }
            
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }

            guard let imageData = data else { return }
            let postPhotoImage = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                self.image = postPhotoImage
            }
        }.resume()
    }
}
