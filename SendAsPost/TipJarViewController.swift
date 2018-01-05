//
//  TipJarViewController.swift
//  SendAsPost
//
//  Created by Andy Brett on 1/5/18.
//  Copyright © 2018 APB. All rights reserved.
//

import UIKit
import StoreKit

class TipJarViewController: UIViewController {
    var spinner = UIActivityIndicatorView()
    let headerLabel = UILabel()
    let tipJar1Button = UIButton()
    let tipJar5Button = UIButton()
    let tipJar20Button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        SKPaymentQueue.default().add(self)
        
        self.view.addSubview(self.spinner)
        self.spinner.activityIndicatorViewStyle = .gray
        self.spinner.hidesWhenStopped = true
        self.spinner.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        
        self.headerLabel.text = "Thanks for your support! ❤️\n\nVisit sendaspost.com for more donation options."
        self.headerLabel.numberOfLines = 0
        self.headerLabel.font = UIFont.defaultFont()
        self.view.addSubview(self.headerLabel)
        self.headerLabel.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.topMargin).offset(10)
            } else {
                make.top.equalTo(self.topLayoutGuide.snp.bottom).offset(10)
            }
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        self.view.addSubview(self.tipJar1Button)
        self.tipJar1Button.setTitle("Tip jar: $1", for: .normal)
        self.tipJar1Button.titleLabel?.font = UIFont.defaultFont()
        self.tipJar1Button.backgroundColor = .darkGray
        self.tipJar1Button.addTarget(self, action: #selector(self.tipJar1ButtonPressed), for: .touchUpInside)
        self.tipJar1Button.setTitleColor(.white, for: .normal)
        self.tipJar1Button.snp.makeConstraints { (make) in
            make.top.equalTo(self.headerLabel.snp.bottom).offset(10)
            make.height.left.right.equalTo(self.headerLabel)
        }
        
        self.view.addSubview(self.tipJar5Button)
        self.tipJar5Button.setTitle("Tip jar: $5", for: .normal)
        self.tipJar5Button.titleLabel?.font = UIFont.defaultFont()
        self.tipJar5Button.backgroundColor = .darkGray
        self.tipJar5Button.addTarget(self, action: #selector(self.tipJar5ButtonPressed), for: .touchUpInside)
        self.tipJar5Button.setTitleColor(.white, for: .normal)
        self.tipJar5Button.snp.makeConstraints { (make) in
            make.top.equalTo(self.tipJar1Button.snp.bottom).offset(10)
            make.height.left.right.equalTo(self.headerLabel)
        }
        
        self.view.addSubview(self.tipJar20Button)
        self.tipJar20Button.setTitle("Tip jar: $20", for: .normal)
        self.tipJar20Button.titleLabel?.font = UIFont.defaultFont()
        self.tipJar20Button.backgroundColor = .darkGray
        self.tipJar20Button.addTarget(self, action: #selector(self.tipJar20ButtonPressed), for: .touchUpInside)
        self.tipJar20Button.setTitleColor(.white, for: .normal)
        self.tipJar20Button.snp.makeConstraints { (make) in
            make.top.equalTo(self.tipJar5Button.snp.bottom).offset(10)
            make.height.left.right.equalTo(self.headerLabel)
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    @objc func tipJar1ButtonPressed() {
        self.tipJarButtonPressed(identifier: "TIPIOS1")
    }
    
    @objc func tipJar5ButtonPressed() {
        self.tipJarButtonPressed(identifier: "TIPIOS5")
    }
    
    @objc func tipJar20ButtonPressed() {
        self.tipJarButtonPressed(identifier: "TIPIOS20")
    }
    
    func tipJarButtonPressed(identifier: String) {
        var prod: SKProduct? = nil
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        delegate.storeKitProducts.forEach { (product) in
            if product.productIdentifier == identifier {
                prod = product
            }
        }
        if prod == nil { return }
        let payment = SKMutablePayment(product: prod!)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TipJarViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchasing:
                self.tipJar1Button.isHidden = true
                self.tipJar5Button.isHidden = true
                self.tipJar20Button.isHidden = true
                self.spinner.startAnimating()
            case .purchased:
                self.tipJar1Button.isHidden = true
                self.tipJar5Button.isHidden = true
                self.tipJar20Button.isHidden = true
                self.spinner.stopAnimating()
                self.headerLabel.text = "🎊🎉🎊🎉🎊🎉🎊\n\nThanks for your support! ❤️\n\nIf you have any comments, suggestions, feature requests, or bug reports, write them on the back of $20 bill and email them to andy@andybrett.com."
                queue.finishTransaction(transaction)
            case .failed:
                self.spinner.stopAnimating()
                self.tipJar1Button.isHidden = false
                self.tipJar5Button.isHidden = false
                self.tipJar20Button.isHidden = false
                queue.finishTransaction(transaction)
            default:
                self.spinner.stopAnimating()
            }
            
        }
    }
}
