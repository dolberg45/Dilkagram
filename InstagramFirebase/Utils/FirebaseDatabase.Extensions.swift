//
//  FirebaseDatabase.Extensions.swift
//  InstagramFirebase
//
//  Created by Григорий on 24.04.2021.
//  Copyright © 2021 Grigoriy Alekseev. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()) {
        
        FirebaseDatabase.Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: userDictionary)
            completion(user)
            
        } withCancel: { (error) in
            print("Failed to fetch user for post", error)
        }
    }
}
