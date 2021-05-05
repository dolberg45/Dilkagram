//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by Григорий on 21.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        return textView
    }()
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        setupNavigationButtons()
        setupImageAndTextViews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupNavigationButtons() {
        
        navigationController?.navigationBar.tintColor = .black
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(nandleShare))
    }
    
    
    
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 120)
        
        
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 90, height: 100)
        
        containerView.addSubview(textView)
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    
    //MARK: - target methods.
    
    @objc func nandleShare() {
        
        //Если textView.text пустой, то дальнейший код выполняться не будет.
        guard let caption = textView.text, caption.count > 0 else { return }
        let filename = NSUUID().uuidString
        guard let image = selectedImage else { return }
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else { return }
        let storageRef = FirebaseStorage.Storage.storage().reference().child("posts").child(filename)
        var postImageUrl = String()
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image in storage: ", err)
                return
            }
            
            storageRef.downloadURL{ (url, err) in
                if err != nil {
                    print("Failed to download url:", err!)
                    return
                }
                
                postImageUrl = url!.absoluteString
                
                print("Successfully uppload post image in storage: \(postImageUrl)")
                
                self.saveToDatabaseWithImageUrl(imageUrl: postImageUrl)
                }
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let uid = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
            guard let postCaption = self.textView.text else { return }
            guard let postImage = self.selectedImage else { return }
            
            let userPostReference = FirebaseDatabase.Database.database().reference().child("posts").child(uid)
            let reference = userPostReference.childByAutoId()
            
            let values = ["imageUrl": imageUrl, "caption": postCaption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
            
            reference.updateChildValues(values) { (err, ref) in
                
                if let err = err {
                    DispatchQueue.main.async {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                    }
                    print("Failed to save post to Database, \(err)")
                    return
                }
                
                print("Successfully saved post to Database")
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                
                NotificationCenter.default.post(name: Constants.Notifications.updateFeedNotification, object: nil)
            }
        }
    }
}
