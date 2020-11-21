//
//  UserProfilePhotoCell.swift
//  InstagramFirebase
//
//  Created by Григорий on 22.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell {
    
    var post: Post? {
        didSet {
            guard let imageUrl = post?.imageUrl else { return }
            
            guard let url = URL(string: imageUrl) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                
                if let err = err {
                    print("Failed to fetch post image", err)
                    return
                }

                guard let imageData = data else { return }
                let postPhotoImage = UIImage(data: imageData)
                
                DispatchQueue.main.async {
                    self.postPhotoImageView.image = postPhotoImage
                }
            }.resume()
        }
    }
    
    let postPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .brown
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postPhotoImageView)
        postPhotoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
