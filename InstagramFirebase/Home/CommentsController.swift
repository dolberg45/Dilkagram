//
//  CommentsController.swift
//  InstagramFirebase
//
//  Created by Григорий on 04.05.2021.
//  Copyright © 2021 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, CommentInputAccessoryViewDelegate {
    
    var post: Post?
    
    let cellId = "cellId"
    
    var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
    }
    
    fileprivate func fetchComments() {
        
        guard let postId = self.post?.id else { return }
        
        let reference = Firebase.Database.database().reference().child("comments").child(postId)
        
        reference.observe(.childAdded) { (snapshot) in
            
            guard let dictionary  = snapshot.value as? [String: Any] else { return }
            
            guard let uid = dictionary["uid"] as? String else { return }
            
            Firebase.Database.fetchUserWithUID(uid: uid) { (user) in
                                
                var comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
                
            }
            
        } withCancel: { (error) in
            print("Failed to observe comments")
        }

    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    lazy var containerView: CommentInputAccessoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
        
//        let containerView = UIView()
//        containerView.backgroundColor = .white
//        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
//        let submitButton = UIButton(type: .system)
//        submitButton.setTitle("Submit", for: .normal)
//        submitButton.setTitleColor(.black, for: .normal)
//        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
//        containerView.addSubview(submitButton)
//        submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -12, width: 50, height: 50)
        
//        containerView.addSubview(self.commentTextFeild)
//        self.commentTextFeild.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: -10, width: 0, height: 0)
        
//        //Линия для выделения области написания комментария.
//        let lineSeparatorView = UIView()
//        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
//        containerView.addSubview(lineSeparatorView)
//        lineSeparatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
//        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
//    let commentTextFeild: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Enter Comment"
//        return textField
//    }()
    
//    @objc func submitButtonTapped() {
//
//        guard let uid = Firebase.Auth.auth().currentUser?.uid else { return }
//
//        let postId = post?.id ?? ""
//        let values = ["text": commentTextFeild.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
//
//        Firebase.Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, reference) in
//
//            if let error = error {
//                print("Failed to insert comment", error)
//            }
//
//            print("Successfully inserted comment")
//
//        }
//    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCollectionViewCell
        
        cell.comment = self.comments[indexPath.row]
        
        return cell
    }
    
    func didSubmit(for comment: String) {
        
        guard let uid = Firebase.Auth.auth().currentUser?.uid else { return }

        let postId = post?.id ?? ""
        let values = ["text": comment, "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]

        Firebase.Database.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (error, reference) in

            if let error = error {
                print("Failed to insert comment", error)
            }

            print("Successfully inserted comment")

            self.containerView.clearCommentTextField()
        }
    }
}

extension CommentsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let customCell = CommentCollectionViewCell(frame: frame)
        customCell.comment = comments[indexPath.row]
        customCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimetedSize =  customCell.systemLayoutSizeFitting(targetSize)
        
        
        let height = max(40 + 8 + 8, estimetedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
