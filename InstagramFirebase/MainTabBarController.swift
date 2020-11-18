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
        
        setupViewControllers()
    }
    
     func setupViewControllers() {
        
        //home
        let homeNavController = templateNavController(unselectedImage: UIImage(, selectedImage: <#T##UIImage#>)
        
        //search
        let searchController = UIViewController()
        let searchNavController = UINavigationController(rootViewController: searchController)
        
        searchNavController.tabBarItem.image = UIImage(named: "search_unselected")
        searchNavController.tabBarItem.selectedImage = UIImage(named: "search_selected")
        
        //user profile
        let layout = UICollectionViewFlowLayout()
        
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        
        userProfileNavController.tabBarItem.image = UIImage(named: "profile_unselected.png")
        userProfileNavController.tabBarItem.selectedImage = UIImage(named: "profile_selected.png")
        
        tabBar.tintColor = .black
        
        viewControllers = [homeNavController, searchNavController, userProfileNavController]
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage) -> UINavigationController {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
    }
}
