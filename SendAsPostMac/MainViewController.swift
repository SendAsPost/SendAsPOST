//
//  MainViewController.swift
//  SendAsPostMac
//
//  Created by Andy Brett on 12/7/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Cocoa
import StoreKit

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var editingCellWithValue: String?
    var storeKitProducts: Array<SKProduct> = []
    
    @IBOutlet var paramsTable: NSTableView!
    @IBOutlet var tipJar1Button: NSButton!
    @IBOutlet var tipJar20Button: NSButton!
    @IBOutlet var tipJar5Button: NSButton!
    @IBOutlet var tipLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.paramsTable.delegate = self
        self.paramsTable.dataSource = self
        
        self.paramsTable.tableColumns[0].headerCell.font = NSFont(name: "Menlo", size: 28)
        
        let request = SKProductsRequest(productIdentifiers: ["TIPMAC1", "TIPMAC5", "TIPMAC20"])
        request.delegate = self
        request.start()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.storeKitProducts = response.products
    }
    
    @IBAction func tipJar1Clicked(_ sender: NSButton) {
        self.tipJarClicked(identifier: "TIPMAC1")
    }
    
    @IBAction func tipJar5Clicked(_ sender: NSButton) {
        self.tipJarClicked(identifier: "TIPMAC5")
    }
    
    @IBAction func tipJar20Clicked(_ sender: NSButton) {
        self.tipJarClicked(identifier: "TIPMAC20")
    }
    
    func tipJarClicked(identifier: String) {
        var prod: SKProduct? = nil
        self.storeKitProducts.forEach { (product) in
            if product.productIdentifier == identifier {
                prod = product
            }
        }
        if prod == nil { return }
        let payment = SKMutablePayment(product: prod!)
        payment.quantity = 1
        SKPaymentQueue.default().add(payment)
    }
    
    
    @IBAction func doubleClicked(_ sender: NSTableView) {
        let row = sender.clickedRow
        let column = sender.clickedColumn
        guard row > -1, column > -1,
            let view = self.paramsTable.view(atColumn: column, row: row, makeIfNecessary: true) as? NSTableCellView else { return }
        
        view.textField?.selectText(self)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        let defaults: UserDefaults = UserDefaults.shared() ?? UserDefaults.standard
        let additionalParameters = defaults.dictionary(forKey: "additionalParams") as? [String : String] ?? [:]
        return additionalParameters.keys.count + 1
    }
    
    func sortedParameters() -> [String] {
        let defaults: UserDefaults = UserDefaults.shared() ?? UserDefaults.standard
        let additionalParameters = defaults.dictionary(forKey: "additionalParams") as? [String : String] ?? [:]
        return additionalParameters.keys.sorted()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let defaults: UserDefaults = UserDefaults.shared() ?? UserDefaults.standard
        var additionalParameters = defaults.dictionary(forKey: "additionalParams") as? [String : String] ?? [:]
        
        if tableView.tableColumns[0] == tableColumn {
            guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "parameterCell"), owner: nil) as? NSTableCellView else { return nil }
            cellView.textField?.delegate = self
            if row >= self.sortedParameters().count {
                cellView.textField?.stringValue = ""
            } else {
                cellView.textField?.stringValue = self.sortedParameters()[row]
            }
            return cellView
        }
        guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "parameterValueCell"), owner: nil) as? NSTableCellView else { return nil }
        cellView.textField?.delegate = self
        
        if row >= self.sortedParameters().count {
            cellView.textField?.stringValue = ""
            return cellView
        }
        cellView.textField?.stringValue = additionalParameters[self.sortedParameters()[row]]!
        
        return cellView
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        self.editingCellWithValue = fieldEditor.string
        return true
    }
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let previousTextFieldString = self.editingCellWithValue else { return true }
        let defaults: UserDefaults = UserDefaults.shared() ?? UserDefaults.standard
        var additionalParameters = defaults.dictionary(forKey: "additionalParams") as? [String : String] ?? [:]
        
        if control.tag == 100 {
            let previousParameterValue = additionalParameters[previousTextFieldString] ?? ""
            additionalParameters.removeValue(forKey: previousTextFieldString)
            additionalParameters[fieldEditor.string] = previousParameterValue
        } else if control.tag == 101 && self.paramsTable.selectedRow >= 0 {
            let parameter = self.sortedParameters()[self.paramsTable.selectedRow]
            additionalParameters[parameter] = fieldEditor.string
        }
        defaults.set(additionalParameters, forKey: "additionalParams")
        defaults.synchronize()
        self.editingCellWithValue = nil
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            //placeholder
        }
    }
}

