//
//  AboutViewController.swift
//  Send As Post
//
//  Created by Andy Brett on 12/5/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import SnapKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About"
        self.view.backgroundColor = .white
        
        let creditLabel = UILabel()
        self.view.addSubview(creditLabel)
        creditLabel.font = UIFont.defaultFont()
        creditLabel.text = "Pigeon Post icon by Intro Mike, from thenounproject.com."
        creditLabel.textColor = .darkGray
        creditLabel.numberOfLines = 0
        creditLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(10)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(10)
            }
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
    }
}
