//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by Григорий on 22.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var posts = [Post]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: Constants.Notifications.updateFeedNotification, object: nil)

        collectionView.backgroundColor = .white
        
        self.collectionView!.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        setupNavigationItems()
        
        fetchAllPosts()
    }
    
    fileprivate func fetchFollowingUserIds() {
        
        guard let currentUserUid = Firebase.Auth.auth().currentUser?.uid else { return }
        
        Firebase.Database.database().reference().child("following").child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
            
            self.collectionView.refreshControl?.endRefreshing()
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            userIdsDictionary.forEach { (key, value) in
                Firebase.Database.fetchUserWithUID(uid: key) { (user) in
                    self.fetchPostsWithUser(user: user)
                }
            }
            
        } withCancel: { (error) in
            print("Failed to fetch following user", error)
        }
    }
    
    fileprivate func fetchAllPosts() {
        self.fetchPosts()
        self.fetchFollowingUserIds()
    }
    
    func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_black"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCollectionViewCell
    
        if posts.count != 0 {
            cell.post = posts[indexPath.row]
        } else {
            print("Error")
        }
        
        cell.delegate = self
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    //Настройка высоты ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 //Username userProfileImageView
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    // MARK: Photo
    
    ///Расшариваем конкретные посты.
    fileprivate func fetchPosts() {
        
        guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        
        //Достаем юзера по UID и достаем все посты юзера
        Firebase.Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    
    ///Достаеам посты юзера
    fileprivate func fetchPostsWithUser(user: User) {
        
        let reference =  FirebaseDatabase.Database.database().reference().child("posts").child(user.uid)
        reference.observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach { (key, value) in
                
                guard let dictionary = value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                //Достаем все лайки.
                guard let uid = Firebase.Auth.auth().currentUser?.uid else { return }
                Firebase.Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value) { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLike = true
                    } else {
                        post.hasLike = false
                    }
                    
                    self.posts.append(post)
                    self.posts.sort { (post1, post2) -> Bool in
                        return post1.creationDate.compare(post2.creationDate) == .orderedDescending
                    }
                    self.collectionView.reloadData()
                    
                } withCancel: { (error) in
                    print("Failed to fetch like info for post: ", error)
                }
            }

        } withCancel: { (err) in
            
            print("Failed to fetch posts: \(err)")
        }
    }
    
    //Target methods
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleCamera() {
        print("Present camera")
        
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        self.present(cameraVC, animated: true, completion: nil)
    }
}



//MARK: - HomePostCollectionViewCellDelegate

extension HomeController: HomePostCollectionViewCellDelegate {
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapLike(for cell: HomePostCollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        var post = self.posts[indexPath.row]

        guard let postId = post.id else { return }
        guard let uid = Firebase.Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: post.hasLike == true ? 0 : 1]
        Firebase.Database.database().reference().child("likes").child(postId).updateChildValues(values) { (error, reference) in
            
            if let error = error {
                print("Failed to like post", error)
            }
            
            print("Succesfully like/notlike post.")
            
            post.hasLike = !post.hasLike
            
            self.posts[indexPath.row] = post
            
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
}
