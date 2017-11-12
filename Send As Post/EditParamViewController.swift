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
    var value : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(self.paramTextField)
        self.paramTextField.placeholder = "Param"
        self.paramTextField.text = self.key
        self.paramTextField.snp.makeConstraints { (make) in
            if #available(iOS 11, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalTo(60)
            }
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(42)
        }
        if self.key != nil {
            self.paramTextField.isEnabled = false
        }
        
        self.view.addSubview(self.valueTextField)
        self.valueTextField.placeholder = "Value"
        self.valueTextField.text = self.value
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
        saveButton.setTitleColor(.black, for: .normal)
        self.view.addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.valueTextField.snp.bottom).offset(10)
        }
        
        if self.key != nil {
            let deleteButton = UIButton()
            deleteButton.addTarget(self, action: #selector(self.deleteButtonPressed), for: .touchUpInside)
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.titleLabel?.textAlignment = .center
            deleteButton.setTitleColor(.red, for: .normal)
            self.view.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(self.view)
                make.top.equalTo(saveButton.snp.bottom).offset(10)
            }
        }
    }
    
    @objc func saveButtonPressed() {
        if self.paramTextField.text == nil {
            return
        }
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        var params = self.additionalParams()
        params[self.paramTextField.text!] = self.valueTextField.text
        defaults?.set(params, forKey: "additionalParams")
        defaults?.synchronize()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func deleteButtonPressed() {
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        var params = self.additionalParams()
        params.removeValue(forKey: self.key!)
        defaults?.set(params, forKey: "additionalParams")
        defaults?.synchronize()
        self.navigationController?.popViewController(animated: true)
    }
    
    func additionalParams() -> [String : String] {
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        return defaults?.dictionary(forKey: "additionalParams") as? [String:String] ?? [:]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
