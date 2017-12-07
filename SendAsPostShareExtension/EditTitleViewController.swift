//
//  EditTitleViewController.swift
//  Send As Post Share Extension
//
//  Created by Andy Brett on 11/17/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import Social
import SnapKit

class EditTitleViewController: UIViewController {
    var parentComposeServiceViewController: ShareViewController?
    var pageTitle: String?
    var textField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit title"
        
        self.view.addSubview(self.textField)
        self.textField.snp.makeConstraints { (make) in
            make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(10)
            make.left.right.equalTo(0)
        }
        self.textField.textAlignment = .center
        self.textField.placeholder = "Page title"
        self.textField.text = self.pageTitle
        self.textField.textColor = .black
        self.textField.becomeFirstResponder()
        
        let saveButton = UIButton()
        self.view.addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.textField.snp.bottom).offset(10)
            make.left.right.equalTo(0)
        }
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.addTarget(self, action: #selector(self.saveButtonPressed), for: .touchUpInside)
    }
    
    @objc func saveButtonPressed() {
        self.navigationController?.popViewController(animated: true)
        self.parentComposeServiceViewController?.pageTitle = self.textField.text
        self.parentComposeServiceViewController?.reloadConfigurationItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
