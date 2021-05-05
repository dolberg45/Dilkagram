//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by Григорий on 22.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit

//Кэш для изображения
var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        
        self.image = nil
        
        //Проверка если уже есть в кэше
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        //Если нет в кэше, то подгружаем
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
            
            imageCache[url.absoluteString] = postPhotoImage
            
            DispatchQueue.main.async {
                self.image = postPhotoImage
            }
        }.resume()
    }
}
