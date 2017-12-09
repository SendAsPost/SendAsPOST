//
//  MainViewController.swift
//  SendAsPostMac
//
//  Created by Andy Brett on 12/7/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    var editingCellWithValue: String?
    
    @IBOutlet var paramsTable: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.paramsTable.delegate = self
        self.paramsTable.dataSource = self
        
        self.paramsTable.tableColumns[0].headerCell.font = NSFont(name: "Menlo", size: 28)
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
}

