//
//  AddParamViewController.swift
//  Send As Post
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import SnapKit

class EditParamViewController: UIViewController {
    var paramTextField = UITextField()
    var valueTextField = UITextField()
    var key : String?
    var originalKey : String?
    var value : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.paramTextField)
        self.paramTextField.placeholder = "Param"
        self.originalKey = self.key
        self.paramTextField.text = self.key
        self.paramTextField.font = UIFont.defaultFont()
        self.paramTextField.autocapitalizationType = .none
        self.paramTextField.autocorrectionType = .no
        self.paramTextField.snp.makeConstraints { (make) in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom)
            }
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(42)
        }
        
        self.view.addSubview(self.valueTextField)
        self.valueTextField.placeholder = "Value"
        self.valueTextField.text = self.value
        self.valueTextField.font = UIFont.defaultFont()
        self.valueTextField.autocapitalizationType = .none
        self.valueTextField.autocorrectionType = .no
        self.valueTextField.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(self.paramTextField.snp.bottom).offset(10)
            make.height.equalTo(42)
        }
        
        let saveButton = UIButton()
        saveButton.addTarget(self, action: #selector(self.saveButtonPressed), for: .touchUpInside)
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.textAlignment = .center
        saveButton.titleLabel?.font = UIFont.defaultFont()
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .darkGray
        self.view.addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.valueTextField.snp.bottom).offset(10)
            make.left.right.height.equalTo(self.valueTextField)
        }
        
        if self.key != nil {
            let deleteButton = UIButton()
            deleteButton.addTarget(self, action: #selector(self.deleteButtonPressed), for: .touchUpInside)
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.titleLabel?.textAlignment = .center
            deleteButton.backgroundColor = .darkGray
            deleteButton.setTitleColor(.red, for: .normal)
            deleteButton.titleLabel?.font = UIFont.defaultFont()
            self.view.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.top.equalTo(saveButton.snp.bottom).offset(10)
                make.left.right.height.equalTo(saveButton)
            }
        }
    }
    
    @objc func saveButtonPressed() {
        var formValid = true
        if self.paramTextField.text == nil || self.paramTextField.text == "" {
            self.paramTextField.layer.borderColor = UIColor.red.cgColor
            self.paramTextField.layer.borderWidth = 1
            formValid = false
        }
        if self.valueTextField.text == nil || self.valueTextField.text == "" {
            self.valueTextField.layer.borderColor = UIColor.red.cgColor
            self.valueTextField.layer.borderWidth = 1
            formValid = false
        }
        if !formValid { return }
        let defaults = UserDefaults.shared()
        var params = self.additionalParams()
        params[self.paramTextField.text!] = self.valueTextField.text
        if self.originalKey != self.paramTextField.text && self.originalKey != nil {
            params.removeValue(forKey: self.originalKey!)
        }
        defaults?.set(params, forKey: "additionalParams")
        defaults?.synchronize()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteButtonPressed() {
        let defaults = UserDefaults.shared()
        var params = self.additionalParams()
        params.removeValue(forKey: self.key!)
        defaults?.set(params, forKey: "additionalParams")
        defaults?.synchronize()
        self.navigationController?.popViewController(animated: true)
    }
    
    func additionalParams() -> [String : String] {
        let defaults = UserDefaults.shared()
        return defaults?.dictionary(forKey: "additionalParams") as? [String:String] ?? [:]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
