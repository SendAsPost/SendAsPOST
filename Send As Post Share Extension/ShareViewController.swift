//
//  ShareViewController.swift
//  Send As Post Share Extension
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import Social
import Alamofire
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        self.placeholder = "Caption"
    }
    
    override func isContentValid() -> Bool {
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        return defaults?.string(forKey: "defaultUrl") != nil
    }
    
    override func didSelectPost() {
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { return }

        for item in items {
            if let attachments = item.attachments as? [NSItemProvider] {
                for attachment in attachments {
                    if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                        attachment.loadFileRepresentation(forTypeIdentifier: kUTTypeImage as String, completionHandler: { (url, error) in
                            if url == nil || error != nil { return }
                            
                            guard let imageData = NSData.init(contentsOf: url!) as Data? else { return }

                            Alamofire.upload(
                                multipartFormData: { multipartFormData in
                                    multipartFormData.append(self.contentText.data(using: .utf8)!, withName: "caption")
                                    multipartFormData.append(imageData, withName: "image")
                                    if let params = defaults?.dictionary(forKey: "additionalParams") as? [String : String] {
                                        for key in params.keys {
                                            if let valueData = params[key]?.data(using: .utf8) {
                                                multipartFormData.append(valueData, withName: key)
                                            }
                                        }
                                    }
                            },
                                to: (defaults?.string(forKey: "defaultUrl"))!,
                                encodingCompletion: { encodingResult in
                                    switch encodingResult {
                                    case .success(let upload, _, _):
                                        upload.responseJSON { response in
                                            debugPrint(response)
                                        }
                                    case .failure(let encodingError):
                                        print(encodingError)
                                    }
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            }
                            )
                        })
                    }
                }
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        let postUrlItem = SLComposeSheetConfigurationItem.init()
        postUrlItem?.title = "POST to:"
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        postUrlItem?.value = defaults?.string(forKey: "defaultUrl") ?? "Choose URL..."
        postUrlItem?.tapHandler = {
            // it would be preferable to do this by overriding viewDidAppear and calling
            // reloadConfigurationItems, but that method isn't being called when the
            // child viewController is popped off the stack, soo....
            let selectUrlViewController = SelectUrlViewController()
            selectUrlViewController.parentComposeServiceViewController = self
            self.pushConfigurationViewController(selectUrlViewController)
        }
        return [postUrlItem as Any]
    }
}
