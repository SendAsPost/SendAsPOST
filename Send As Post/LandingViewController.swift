//
//  LandingViewController.swift
//  Send As Post
//
//  Created by Andy Brett on 12/5/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import SnapKit

class LandingViewController: UIViewController {
    let margin = 10

    @IBOutlet var explanationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Send as POST"

        self.view.addSubview(self.explanationLabel)
        self.explanationLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(self.margin)
                make.left.equalTo(self.view.safeAreaLayoutGuide.snp.leftMargin).offset(self.margin)
                make.right.equalTo(self.view.safeAreaLayoutGuide.snp.rightMargin).offset(-self.margin)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
                make.left.equalTo(self.margin)
                make.right.equalTo(-self.margin)
            }
        }
        
        let paramsButton = UIButton()
        self.view.addSubview(paramsButton)
        paramsButton.setTitleColor(.white, for: .normal)
        paramsButton.titleLabel?.font = UIFont.defaultFont()
        paramsButton.backgroundColor = .darkGray
        paramsButton.addTarget(self, action: #selector(self.paramsButtonPressed), for: .touchUpInside)
        paramsButton.setTitle("Add Additional Parameters", for: .normal)
        paramsButton.snp.makeConstraints { (make) in
            make.top.equalTo(explanationLabel.snp.bottom).offset(self.margin)
            make.left.right.equalTo(explanationLabel)
        }
    }
    
    @objc func paramsButtonPressed() {
        self.navigationController?.pushViewController(ConfigViewController(), animated: true)
    }
}
