//
//  SelectUrlViewController.swift
//  Send As Post Share Extension
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit

class SelectUrlViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "POST to:"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func urlsList() -> Array<String> {
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        return defaults?.array(forKey: "urls") as? [String] ?? []
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urlsList().count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "urlCell") else { return UITableViewCell() }
        if indexPath.row < self.urlsList().count {
            cell.textLabel?.text = self.urlsList()[indexPath.row]
        } else {
            cell.textLabel?.text = "Add URL..."
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.urlsList().count {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.pushViewController(AddUrlViewController(), animated: true)
        }
    }
}
