//
//  User.swift
//  InstagramFirebase
//
//  Created by Григорий on 22.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import Foundation

struct User {
    let userName: String
    let profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.userName = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
