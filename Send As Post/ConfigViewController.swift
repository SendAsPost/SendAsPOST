//
//  ViewController.swift
//  Send As Post
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import SnapKit

class ConfigViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView = UITableView()
    
    override func viewDidLoad() {
        self.title = "Additional params"
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "paramCell")
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func additionalParams() -> [String : String] {
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        return defaults?.dictionary(forKey: "additionalParams") as? [String:String] ?? [:]
    }
    
    func sortedKeys() -> [String] {
        return self.additionalParams().keys.sorted()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.additionalParams().keys.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "paramCell") else { return UITableViewCell() }
        if indexPath.row < self.additionalParams().keys.count {
            let key = self.sortedKeys()[indexPath.row]
            cell.textLabel?.text = "\(key): \(self.additionalParams()[key]!)"
        } else {
            cell.textLabel?.text = "Add param..."
        }
        cell.textLabel?.font = UIFont.defaultFont()
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.additionalParams().keys.count {
            let editParamViewController = EditParamViewController()
            editParamViewController.key = self.sortedKeys()[indexPath.row]
            editParamViewController.value = self.additionalParams()[self.sortedKeys()[indexPath.row]]
            self.navigationController?.pushViewController(editParamViewController, animated: true)
        } else {
            self.navigationController?.pushViewController(EditParamViewController(), animated: true)
        }
    }
}

