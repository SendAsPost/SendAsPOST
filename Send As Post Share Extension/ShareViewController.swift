//
//  ShareViewController.swift
//  Send As Post Share Extension
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        self.placeholder = "Caption"
    }
    
    override func isContentValid() -> Bool {
        let defaults = UserDefaults(suiteName: "group.sendaspost")
        return defaults?.string(forKey: "defaultUrl") != nil
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        let postUrlItem = SLComposeSheetConfigurationItem.init()
        postUrlItem?.title = "POST to:"
        let defaults = UserDefaults(suiteName: "group.sendaspost")
        postUrlItem?.value = defaults?.string(forKey: "defaultUrl") ?? "Choose URL..."
        postUrlItem?.tapHandler = {
            let viewController = SelectUrlViewController()
            self.pushConfigurationViewController(viewController)
        }
        return [postUrlItem]
    }
}
