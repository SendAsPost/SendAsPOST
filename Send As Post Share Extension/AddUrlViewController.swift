//
//  AddUrlViewController.swift
//  Send As Post Share Extension
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import SnapKit

class AddUrlViewController: UIViewController, UITextFieldDelegate {
    var urlTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add URL"
        
        self.urlTextField.placeholder = "e.g. https://andybrett.com"
        self.urlTextField.textAlignment = .center
        self.urlTextField.text = "https://"
        self.urlTextField.textColor = .black
        self.urlTextField.keyboardType = .URL
        self.urlTextField.autocapitalizationType = .none
        self.view.addSubview(self.urlTextField)
        self.urlTextField.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
        }
        self.urlTextField.delegate = self
        self.urlTextField.becomeFirstResponder()
        
        let addUrlButton = UIButton()
        addUrlButton.setTitleColor(.black, for: .normal)
        addUrlButton.setTitle("Add", for: .normal)
        addUrlButton.addTarget(self, action: #selector(self.addUrlButtonPressed), for: .touchUpInside)
        self.view.addSubview(addUrlButton)
        addUrlButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(0)
            make.top.equalTo(self.urlTextField.snp.bottom)
            make.height.equalTo(42)
            make.centerX.equalTo(self.view)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validUrl(urlString: String?) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_:])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    
    @objc func addUrlButtonPressed() {
        if self.validUrl(urlString: self.urlTextField.text) {
            let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
            defaults?.set(self.urlTextField.text, forKey: "defaultUrl")
            var urls = defaults?.array(forKey: "urls") as? [String] ?? []
            urls.append(self.urlTextField.text!)
            defaults?.set(urls, forKey: "urls")
            defaults?.synchronize()
            self.navigationController?.popViewController(animated: true)
        } else {
            self.urlTextField.textColor = .red
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.textColor = .black
        return true
    }
}
