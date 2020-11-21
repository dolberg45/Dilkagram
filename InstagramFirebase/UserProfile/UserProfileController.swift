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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.backgroundColor = .white
        self.navigationItem.title = Auth.auth().currentUser?.uid
        fetchUser()
        
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: "cellId")
        
        setupLogOutButton()
        
        fetchPost()
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "cellId", for: indexPath) as! UserProfilePhotoCell
        
        cell.post = posts[indexPath.item]
        
        return cell
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
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    
    var user: User?
    
    fileprivate func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        FirebaseDatabase.Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot.value ?? "")
            
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            //Создали структуру User с полями и конструктором вместо двух строчек снизу.
//            let profileImageUrl = dictionary["profileImageUrl"] as? String
//            let username = dictionary["username"] as? String
            
            self.user = User(dictionary: dictionary)
            
            self.navigationItem.title = self.user?.userName
            
            self.collectionView.reloadData()
            
        } withCancel: { (err) in
            print("Failed to fetch user", err)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    //MARK:- Working with posts
    
    var posts = [Post]()
    
    fileprivate func fetchPost() {
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        
        let reference =  FirebaseDatabase.Database.database().reference().child("posts").child(uid)
        reference.observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { (key, value) in
                //print("Key: \(key), Value: \(value)")
                
                guard let dictionary = value as? [String: Any] else { return }
                
                let imageUrl = dictionary["imageUrl"] as? String
                
                let post = Post(dictionary: dictionary)
                self.posts.append(post)
            }
            
            self.collectionView.reloadData()
            
        } withCancel: { (err) in
            
            print("Failed to fetch posts: \(err)")
        }

    }
}
