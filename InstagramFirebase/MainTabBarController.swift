//
//  MainTabBarController.swift
//  InstagramFirebase
//
//  Created by Григорий on 24/09/2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Показать, если не авторизован.
        DispatchQueue.main.async {
            let loginController = LoginController()
            
            let navigationController = UINavigationController(rootViewController: loginController)
            navigationController.modalPresentationStyle = .overFullScreen
            
            if FirebaseAuth.Auth.auth().currentUser == nil {
                self.present(navigationController, animated: false, completion: nil)
            }
            return
        }
        
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let navController = UINavigationController(rootViewController: userProfileController)
        
        navController.tabBarItem.image = UIImage(named: "profile_unselected.png")
        navController.tabBarItem.selectedImage = UIImage(named: "profile_selected.png")
        
        tabBar.tintColor = .black
            
        viewControllers = [navController]
    }
}
