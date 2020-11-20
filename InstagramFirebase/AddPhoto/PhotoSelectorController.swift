//
//  PhotoSelectorController.swift
//  InstagramFirebase
//
//  Created by Григорий on 21.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit

class PhotoSelectorController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .yellow
        
        setupNavigationButtons()
    }
    
    fileprivate func setupNavigationButtons() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
}
