//
//  ShareViewController.swift
//  Send As Post Share Extension
//
//  Created by Andy Brett on 11/11/17.
//  Copyright © 2017 APB. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    var pageTitle: String?
    var savedContextText: String?

    override func viewDidLoad() {
        self.placeholder = "Caption"
    }
    
    func saveContextText() {
        self.savedContextText = self.textView.text
    }
    
    override func isContentValid() -> Bool {
        let defaults = UserDefaults.shared()
        return defaults?.string(forKey: "defaultUrl") != nil
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func didSelectPost() {
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { self.logErrorAndCompleteRequest(error: nil); return }
        if items.count == 0 { self.logErrorAndCompleteRequest(error: nil); return }
        let parameters = ["caption": self.contentText.trimmingCharacters(in: .whitespacesAndNewlines)]
        for item in items {
            guard let attachments = item.attachments as? [NSItemProvider] else { continue }
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    if #available(iOSApplicationExtension 11.0, *) {
                        attachment.loadFileRepresentation(forTypeIdentifier: kUTTypeImage as String, completionHandler: { (url, error) in
                            if url == nil || error != nil {
                                self.logErrorAndCompleteRequest(error: error); return }
                            guard let imageData = NSData.init(contentsOf: url!) as Data? else {
                                self.logErrorAndCompleteRequest(error: error); return }
                            RequestManager.uploadImage(imageData: imageData, parameters: parameters, encodingCompletion: {
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            })
                        })
                    } else {
                        attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (decoder, error) in
                            if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                            
                            if let url = decoder as? URL {
                                guard let imageData = NSData.init(contentsOf: url) as Data? else {
                                    self.logErrorAndCompleteRequest(error: error); return }
                                RequestManager.uploadImage(imageData: imageData, parameters: parameters, encodingCompletion: {
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                })
                            } else if let image = decoder as? UIImage {
                                guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                                    self.logErrorAndCompleteRequest(error: error); return }
                                RequestManager.uploadImage(imageData: imageData, parameters: parameters, encodingCompletion: {
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                })
                            }
                        })
                    }
                } else if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (decoder, error) in
                        if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                        guard let dictionary = decoder as? NSDictionary else {
                            self.logErrorAndCompleteRequest(error: error); return }
                        guard let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary else {
                            self.logErrorAndCompleteRequest(error: error); return }
                        let parameters = [
                            "url": results.value(forKey: "URL") as? String,
                            "comment": self.contentText,
                            "title": self.pageTitle ?? "",
                            "quote": results.value(forKey: "selectedText") as? String
                        ] as? [String: String]
                        let request = RequestManager.createRequest(imageData: nil, parameters: parameters)
                        let task = BackgroundUploader.shared.session.uploadTask(withStreamedRequest: request)
                        task.resume()
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    })
                } else {
                    self.logErrorAndCompleteRequest(error: nil)
                }
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        var items: [Any] = []
        let postUrlItem = SLComposeSheetConfigurationItem()
        postUrlItem?.title = "POST to:"
        let defaults = UserDefaults.shared()
        postUrlItem?.value = defaults?.string(forKey: "defaultUrl") ?? "Choose URL..."
        postUrlItem?.tapHandler = {
            // it would be preferable to do this by overriding viewDidAppear and calling
            // reloadConfigurationItems, but that method isn't being called when the
            // child viewController is popped off the stack, soo....
            let selectUrlViewController = SelectUrlViewController()
            selectUrlViewController.parentComposeServiceViewController = self
            self.saveContextText()
            self.pushConfigurationViewController(selectUrlViewController)
        }
        items.append(postUrlItem as Any)
        
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] else { return items }
        if items.count == 0 { return items }
        
        for item in inputItems {
            guard let attachments = item.attachments as? [NSItemProvider] else { continue }
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    self.placeholder = "Comment (optional)"
                    self.textView.text = self.savedContextText ?? ""
                    
                    let titleItem = SLComposeSheetConfigurationItem()
                    titleItem?.title = "Title:"
                    titleItem?.valuePending = true
                    titleItem?.tapHandler = {
                        let editTitleViewController = EditTitleViewController()
                        editTitleViewController.pageTitle = titleItem?.value
                        editTitleViewController.parentComposeServiceViewController = self
                        self.saveContextText()
                        self.pushConfigurationViewController(editTitleViewController)
                    }
                    items.append(titleItem as Any)
                    
                    attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (decoder, error) in
                        if error != nil { return }
                        guard let dictionary = decoder as? NSDictionary else { return }
                        guard let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary else { return }
                        
                        if self.pageTitle == nil {
                            if let title = results.value(forKey: "title") as? String {
                                DispatchQueue.main.async {
                                    titleItem?.value = title
                                    titleItem?.valuePending = false
                                    self.pageTitle = title
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                titleItem?.valuePending = false
                                titleItem?.value = self.pageTitle
                            }
                        }
                    })
                }
            }
        }
        return items
    }    
}
