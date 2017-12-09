//
//  ShareViewController.swift
//  SendAsPostMacShareExtension
//
//  Created by Andy Brett on 12/7/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Cocoa

class ShareViewController: NSViewController, NSMenuDelegate, NSComboBoxDelegate {
    
    @IBOutlet var sendButton: NSButtonCell!
    @IBOutlet var urlComboBox: NSComboBox!
    @IBOutlet var firstFieldLabel: NSTextField!
    @IBOutlet var firstField: NSTextField!
    @IBOutlet var secondFieldLabel: NSTextField!
    @IBOutlet var secondField: NSTextField!
    @IBOutlet var errorLabel: NSTextField!
    
    override func loadView() {
        super.loadView()
        self.title = "Send As POST"

        self.urlComboBox.delegate = self
        self.urlComboBox.removeAllItems()
        self.urlComboBox.completes = true
        self.urlComboBox.placeholderString = "Add URL..."
        let defaults: UserDefaults = UserDefaults.shared() ?? UserDefaults.standard
        if let defaultURL = defaults.string(forKey: "defaultUrl") {
            self.urlComboBox.stringValue = defaultURL
        }
        let urls = defaults.array(forKey: "urls") as? [String] ?? []
        self.urlComboBox.addItems(withObjectValues: urls)
        
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { self.logErrorAndCompleteRequest(error: nil); return }
        if items.count == 0 { self.logErrorAndCompleteRequest(error: nil); return }
        for item in items {
            guard let attachments = item.attachments as? [NSItemProvider] else { continue }
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    self.firstFieldLabel.stringValue = "Caption:"
                    self.firstField.stringValue = ""
                    self.secondFieldLabel.isHidden = true
                    self.secondField.isHidden = true
                } else if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    self.firstFieldLabel.stringValue = "Title:"
                    self.firstField.stringValue = ""
                    self.secondFieldLabel.isHidden = false
                    self.secondField.isHidden = false
                    self.secondFieldLabel.stringValue = "Comment:"
                    attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (decoder, error) in
                        if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                        if let dictionary = decoder as? NSDictionary {
                            if let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary {
                                if let title = results.value(forKey: "title") as? String {
                                    self.firstField.stringValue = title
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        self.didSelectPost()
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    func didSelectPost() {
        if self.urlComboBox.stringValue.validUrl() {
            self.errorLabel.isHidden = true
            let defaults: UserDefaults = UserDefaults.shared() ?? UserDefaults.standard
            let newURL = self.urlComboBox.stringValue
            defaults.set(newURL, forKey: "defaultUrl")
            var urls = defaults.array(forKey: "urls") as? [String] ?? []
            if !urls.contains(newURL) { urls.insert(newURL, at: 0) }
            defaults.set(urls, forKey: "urls")
            defaults.synchronize()
        } else {
            self.errorLabel.isHidden = false
            self.urlComboBox.backgroundColor = .red
            return
        }
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { self.logErrorAndCompleteRequest(error: nil); return }
        if items.count == 0 { self.logErrorAndCompleteRequest(error: nil); return }
        let parameters = ["caption": self.firstField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)]
        for item in items {
            guard let attachments = item.attachments as? [NSItemProvider] else { continue }
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (decoder, error) in
                        if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                        
                        if let url = decoder as? URL {
                            guard let imageData = NSData.init(contentsOf: url) as Data? else {
                                self.logErrorAndCompleteRequest(error: error); return }
                            RequestManager.uploadImage(imageData: imageData, parameters: parameters, encodingCompletion: {
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            })
                        } else if let image = decoder as? NSImage {
                            guard let bitRep = image.representations.first as? NSBitmapImageRep else {
                                self.logErrorAndCompleteRequest(error: error); return
                            }

                            guard let imageData = bitRep.representation(using: .jpeg, properties: [:]) else {
                                self.logErrorAndCompleteRequest(error: error); return
                            }
                            RequestManager.uploadImage(imageData: imageData, parameters: parameters, encodingCompletion: {
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            })
                        }
                    })
                } else if attachment.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    attachment.loadItem(forTypeIdentifier: kUTTypePropertyList as String, options: nil, completionHandler: { (decoder, error) in
                        if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                        guard let dictionary = decoder as? NSDictionary else {
                            self.logErrorAndCompleteRequest(error: error); return }
                        guard let results = dictionary.value(forKey: NSExtensionJavaScriptPreprocessingResultsKey) as? NSDictionary else {
                            self.logErrorAndCompleteRequest(error: error); return }
                        let parameters = [
                            "url": results.value(forKey: "URL") as? String,
                            "comment": self.secondField.stringValue,
                            "title": self.firstField.stringValue,
                            "quote": results.value(forKey: "selectedText") as? String
                            ] as? [String: String]
                        let request = RequestManager.createRequest(imageData: nil, parameters: parameters)
                        let task = BackgroundUploader.shared.session.uploadTask(withStreamedRequest: request)
                        task.resume()
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    })
                } else if attachments.index(of: attachment) == attachments.count - 1 {
                    // if it's the last attachment
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
            }
        }
    }
}
