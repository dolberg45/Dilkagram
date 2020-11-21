//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Григорий on 04.10.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        didSet {
            setUpProfileImage()
            //Задаем лабел под аватаркой как username.
            usernameLabel.text = user?.userName
        }
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        return imageView
    }()
    
    let gridButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "grid.png"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "list.png"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ribbon.png"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let postsLabel: UILabel = {
       let label = UILabel()
        
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        
        label.attributedText = attributedText
        
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followersLabel: UILabel = {
       let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "123\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let followingLabel: UILabel = {
       let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "70\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        //Задаем цвет границы
        button.layer.borderColor = UIColor.lightGray.cgColor
        //Задаем ширину границы
        button.layer.borderWidth = 1
        //Задаем округленные края для границы
        button.layer.cornerRadius = 3
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 22, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        //Закругление изображения
        profileImageView.layer.cornerRadius = 80 / 2
        //Соответствие внутреннего вложения и размера элемента.
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        setupBottomToolBar()
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 27, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setupUserStats()
        setupEditProfileButton()
    }
    
    fileprivate func setupEditProfileButton() {
        addSubview(self.editProfileButton)
        self.editProfileButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: profileImageView.bottomAnchor, right: followingLabel.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
        self.editProfileButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: - Method для добавление трех лейблов (колл. постов, подписчиков, подписок) рядом с аватаркой.
    fileprivate func setupUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: -5, width: 0, height: 50)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setupBottomToolBar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
    
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        topDividerView.translatesAutoresizingMaskIntoConstraints = false
        bottomDividerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //Метод для загрузка и инициализации изображения из Firebase в зону для аватарки.
    fileprivate func setUpProfileImage() {
        guard let profileImageUrl = user?.profileImageUrl else { return }
        
        guard let url = URL(string: profileImageUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            //Проверьте наличие ошибки, затем создайте изображение, используя данные(data).
            if let err = err {
                print("Failed to fetch profile image", err)
                return
            }
            //Возможно, проверьте статус ответа 200 (HTTP OK)

            guard let data = data else { return }
            let firebaseImage = UIImage(data: data)
            
            //Используем DispatchQueue чтобы использовать инициализацю изображения из главного(main) потока.
            DispatchQueue.main.async {
                self.profileImageView.image = firebaseImage
            }
        }.resume()
    }
    
    
}
