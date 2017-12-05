//
//  SetupViewController.swift
//  Send As Post
//
//  Created by Andy Brett on 12/5/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Initial Setup"
        self.view.backgroundColor = .white
        
        let infoLabel = UILabel()
        self.view.addSubview(infoLabel)
        infoLabel.font = UIFont.defaultFont()
        infoLabel.text = "To set up Send as POST the first time, you'll have to scroll to the right from the Share menu and tap \"More\". Then toggle on Send as POST. You'll only have to do this once."
        infoLabel.textColor = .darkGray
        infoLabel.numberOfLines = 0
        infoLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(10)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(10)
            }
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        let screenshot = UIImageView(image: UIImage(named: "Setup"))
        screenshot.contentMode = .scaleAspectFit
        self.view.addSubview(screenshot)
        screenshot.snp.makeConstraints { (make) in
            make.left.right.equalTo(infoLabel)
            make.top.equalTo(infoLabel.snp.bottom).offset(10)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin).offset(-10)
            } else {
                make.bottom.equalTo(self.bottomLayoutGuide.snp.top).offset(-10)
            }
        }
        
    }
}
