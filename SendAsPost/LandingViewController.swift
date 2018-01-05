//
//  LandingViewController.swift
//  Send As Post
//
//  Created by Andy Brett on 12/5/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    let margin = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Send As POST"
        
        let setupButton = UIButton()
        self.view.addSubview(setupButton)
        setupButton.setTitle("Setup", for: .normal)
        setupButton.titleLabel?.font = UIFont.defaultFont()
        setupButton.backgroundColor = .darkGray
        setupButton.addTarget(self, action: #selector(self.setupButtonPressed), for: .touchUpInside)
        setupButton.setTitleColor(.white, for: .normal)
        setupButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(self.margin)
                make.left.equalTo(self.view.safeAreaLayoutGuide.snp.leftMargin).offset(self.margin)
                make.right.equalTo(self.view.safeAreaLayoutGuide.snp.rightMargin).offset(-self.margin)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
                make.left.equalTo(self.margin)
                make.right.equalTo(-self.margin)
            }
            make.height.equalTo(62)
        }
        
        let paramsButton = UIButton()
        self.view.addSubview(paramsButton)
        paramsButton.setTitle("Parameters", for: .normal)
        paramsButton.titleLabel?.font = UIFont.defaultFont()
        paramsButton.backgroundColor = .darkGray
        paramsButton.addTarget(self, action: #selector(self.paramsButtonPressed), for: .touchUpInside)
        paramsButton.setTitleColor(.white, for: .normal)
        paramsButton.snp.makeConstraints { (make) in
            make.top.equalTo(setupButton.snp.bottom).offset(self.margin)
            make.height.left.right.equalTo(setupButton)
        }
        
        let aboutButton = UIButton()
        self.view.addSubview(aboutButton)
        aboutButton.setTitle("About", for: .normal)
        aboutButton.titleLabel?.font = UIFont.defaultFont()
        aboutButton.backgroundColor = .darkGray
        aboutButton.addTarget(self, action: #selector(self.aboutButtonPressed), for: .touchUpInside)
        aboutButton.setTitleColor(.white, for: .normal)
        aboutButton.snp.makeConstraints { (make) in
            make.top.equalTo(paramsButton.snp.bottom).offset(self.margin)
            make.height.left.right.equalTo(setupButton)
        }
        
        let tipJarButton = UIButton()
        self.view.addSubview(tipJarButton)
        tipJarButton.setTitle("Tip jar", for: .normal)
        tipJarButton.titleLabel?.font = UIFont.defaultFont()
        tipJarButton.backgroundColor = .darkGray
        tipJarButton.addTarget(self, action: #selector(self.tipJarButtonPressed), for: .touchUpInside)
        tipJarButton.setTitleColor(.white, for: .normal)
        tipJarButton.snp.makeConstraints { (make) in
            make.top.equalTo(aboutButton.snp.bottom).offset(self.margin)
            make.height.left.right.equalTo(setupButton)
        }
    }
    
    @objc func setupButtonPressed() {
        self.navigationController?.pushViewController(SetupViewController(), animated: true)
    }
    
    @objc func paramsButtonPressed() {
        self.navigationController?.pushViewController(ParametersViewController(), animated: true)
    }
    
    @objc func aboutButtonPressed() {
        self.navigationController?.pushViewController(AboutViewController(), animated: true)
    }
    
    @objc func tipJarButtonPressed() {
        self.navigationController?.pushViewController(TipJarViewController(), animated: true)
    }
}
