//
//  Comment.swift
//  InstagramFirebase
//
//  Created by Григорий on 04.05.2021.
//  Copyright © 2021 Grigoriy Alekseev. All rights reserved.
//

import Foundation

struct Comment {
    
    var user: User
    
    let text: String
    let uid: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
