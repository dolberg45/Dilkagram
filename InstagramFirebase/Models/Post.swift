//
//  Post.swift
//  InstagramFirebase
//
//  Created by Григорий on 22.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import Foundation

struct Post {
    let imageUrl: String
    
    init(dictionary: [String: Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
    }
}
