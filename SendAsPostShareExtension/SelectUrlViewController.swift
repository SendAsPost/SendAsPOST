//
//  SelectUrlViewController.swift
//  Send As Post Share Extension
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import SnapKit
import Social

class SelectUrlViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView = UITableView()
    var parentComposeServiceViewController : SLComposeServiceViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "POST to:"
        self.navigationItem.backBarButtonItem?.title = "Back"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "urlCell")
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        self.parentComposeServiceViewController?.reloadConfigurationItems()
        self.parentComposeServiceViewController?.validateContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func urlsList() -> Array<String> {
        let defaults = UserDefaults.shared()
        return defaults?.array(forKey: "urls") as? [String] ?? []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urlsList().count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "urlCell") else { return UITableViewCell() }
        if indexPath.row < self.urlsList().count {
            let url = self.urlsList()[indexPath.row]
            cell.textLabel?.text = url
            let defaults = UserDefaults.shared()
            if url == defaults?.string(forKey: "defaultUrl") {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.textLabel?.text = "Add URL..."
        }
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.urlsList().count {
            let defaults = UserDefaults.shared()
            defaults?.set(self.urlsList()[indexPath.row], forKey: "defaultUrl")
            defaults?.synchronize()
            self.navigationController?.popViewController(animated: true)
            self.parentComposeServiceViewController?.reloadConfigurationItems()
            self.parentComposeServiceViewController?.validateContent()
        } else {
            let addUrlViewController = AddUrlViewController()
            addUrlViewController.parentComposeServiceViewController = self.parentComposeServiceViewController
            self.navigationController?.pushViewController(addUrlViewController, animated: true)
        }
    }
}
