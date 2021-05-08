//
//  CommentInputAccessoryView.swift
//  InstagramFirebase
//
//  Created by Григорий on 07.05.2021.
//  Copyright © 2021 Grigoriy Alekseev. All rights reserved.
//

import UIKit
import Firebase

protocol CommentInputAccessoryViewDelegate {
    func didSubmit(for comment: String)
}

class CommentInputAccessoryView: UIView {
    
    var delegate: CommentInputAccessoryViewDelegate?
    
    lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    fileprivate let commentTextView: CommentInputTextView = {
        let textView = CommentInputTextView()
        textView.isScrollEnabled = false
//        textView.placeholder = "Enter Comment"
        textView.font = UIFont.systemFont(ofSize: 18)
        return textView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //1
        autoresizingMask = .flexibleHeight
        
        self.addSubview(submitButton)
        submitButton.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: -12, width: 50, height: 50)
        
        //3
        self.addSubview(commentTextView)
        commentTextView.anchor(top: topAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 0, height: 0)
        
        setupLineSeparator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLineSeparator() {
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    @objc func submitButtonTapped() {
        
        guard let commentText = commentTextView.text else { return }
        
        delegate?.didSubmit(for: commentText)
    }
    
    func clearCommentTextField() {
        commentTextView.text = nil
        commentTextView.showPlaceholderLabel()
    }
    
    //2
    override var intrinsicContentSize: CGSize {
        return .zero
    }
}
