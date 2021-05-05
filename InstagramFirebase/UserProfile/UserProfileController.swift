//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Григорий on 04.10.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    
    var userId: String?
    
    var isGridView = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = .white
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        setupLogOutButton()
        
        fetchUser()
    }
    
    fileprivate func setupLogOutButton() {
        //Добавляем кнопку в navigation bar справа.
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear.png"), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (_) in
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let loginController = LoginController()
                let navigationController = UINavigationController(rootViewController: loginController)
                navigationController.modalPresentationStyle = .overFullScreen
                
                self.present(navigationController, animated: true, completion: nil)
                
            } catch let sighOutError {
                print("Failed to sign out: \(sighOutError)")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("Отмена выхода из аккаунта.")
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "cellId", for: indexPath) as! UserProfilePhotoCell
            
            cell.post = posts[indexPath.item]
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCollectionViewCell
            
            cell.post = posts[indexPath.item]
            
            return cell
        }
    }
    
    //Метод уменьшает расстояние между ячейками.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //Метод задает размер ячейки.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            
            var height: CGFloat = 40 + 8 + 8 //Username userProfileImageView
            height += view.frame.width
            height += 50
            height += 60
            
            return CGSize(width: view.frame.width, height: height)
        }
        
    }
    
    
    var user: User?
    
    fileprivate func fetchUser() {
        
        let uid = userId ?? (Firebase.Auth.auth().currentUser?.uid ?? "")
        
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
        
        Firebase.Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.userName
            
            self.collectionView.reloadData()
            
            self.fetchOrderedPosts()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        header.delegate = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    //MARK:- Working with posts
    
    var posts = [Post]()
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = user?.uid else { return }

        let reference =  FirebaseDatabase.Database.database().reference().child("posts").child(uid)
        
        reference.queryOrdered(byChild: "creationDate").observe(.childAdded) { [self] (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            guard let user = user else { return }
            
            let post = Post(user: user, dictionary: dictionary)
            self.posts.append(post)
            
            self.collectionView.reloadData()
            
        } withCancel: { (err) in
            print("Failed to fetch ordered posts: ", err)
        }

    }
    
    fileprivate func fetchPosts() {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        
        let reference =  FirebaseDatabase.Database.database().reference().child("posts").child(uid)
        reference.observeSingleEvent(of: .value) { [self] (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { (key, value) in
                //print("Key: \(key), Value: \(value)")
                
                guard let dictionary = value as? [String: Any] else { return }
                
                let post = Post(user: user!, dictionary: dictionary)
                self.posts.append(post)
            }
            
            self.collectionView.reloadData()
            
        } withCancel: { (err) in
            
            print("Failed to fetch posts: \(err)")
        }

    }
}

extension UserProfileController: UserProfileHeaderDelegate {
    
    func changeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    func changeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
}
