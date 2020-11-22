//
//  LoginController.swift
//  InstagramFirebase
//
//  Created by Григорий on 16.11.2020.
//  Copyright © 2020 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        
        let logoImageView = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        return view
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sigh Up", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        
        button.addTarget(self, action: #selector(handleShowSighUp), for: .touchUpInside)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        //Убрали верхнюю часть navigation контроллера.
        navigationController?.isNavigationBarHidden = true

        view.backgroundColor = .white
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 0, width: 0, height: 50)
        
        
        setupInputFields()
    }
    
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: -40, width: 0, height: 140)
        
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 &&
            //usernameTextField.text?.count ?? 0 > 0  &&
            passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            //Кнопка регистрации работает, только если все поля заполнены
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            //Кнопка не работает
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    
    
    //MARK: - Target methods.
    
    @objc fileprivate func handleShowSighUp() {
        let sighUpController = SighUpController()
        navigationController?.pushViewController(sighUpController, animated: true)
    }
    
    @objc fileprivate func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            
            if let err = err {
                print("Failed to sign in with email: ", err)
                return
            }
            
            print("Successfully logged back in with user:", result?.user.uid ?? "")
            
            guard let mainTabBarController = UIApplication.shared.windows.first(where: {$0.isKeyWindow})?.rootViewController as? MainTabBarController else { return }
            
            mainTabBarController.setupViewControllers()
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
//    @objc func handleSignUp() {
//        guard let email = emailTextField.text, email.count > 0 else { return }
//        guard let username = usernameTextField.text, username.count > 0 else { return }
//        guard let password = passwordTextField.text, password.count > 0 else { return }
//
//        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
//            if let err = err {
//                print("Failed to create user: \(err)")
//                let alertController = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
//                            let action = UIAlertAction(title: "Okey", style: .default) { (action) in
//                            }
//
//                    alertController.addAction(action)
//                    self.present(alertController, animated: true, completion: nil)
//                return
//            }
//
//            print("Successfully created user: \(result!)")
//
//            guard let image = self.plusPhotoButton.imageView?.image else { return }
//            guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
//
//            let filename = NSUUID().uuidString
//            let storageRef = Storage.storage().reference().child("profile_image").child(filename)
//            var profileImageUrl: String = "";
//
//            storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
//                if let err = err {
//                    print("Failed to upload profile image: ", err)
//                    return
//                }
//
//                storageRef.downloadURL { (url, err) in
//                if err != nil {
//                    print("Failed to download url:", err!)
//                    return
//                }
//                    profileImageUrl = url!.absoluteString
//                    print("Successfully uppload profile image - \(profileImageUrl)")
//                    if let result = result {
//                        print("Successfully created user: \(result)")
//                        guard let uid = Auth.auth().currentUser?.uid else { return }
//                        let dictionaryValues = ["username" : username, "profileImageUrl": profileImageUrl]
//                        let values = [uid : dictionaryValues]
//
//                        Database.database().reference().child("users").updateChildValues(values) { (err, ref) in
//
//                            if let err = err {
//                                print("Failed to save user into database: ", err)
//                                return
//                            }
//
//                            print("Successfully saved user info to database")
//
//                        }
//                    }
//                }
//            }
//        }
//    }
}
