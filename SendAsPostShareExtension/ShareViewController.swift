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

struct BackgroundUploader {
    
    static let shared = BackgroundUploader()
    
    let session: URLSession = {
        let configName = "com.sendaspost.sendaspost.background"
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: configName)
        sessionConfig.sharedContainerIdentifier = "group.sendaspost.sendaspost"
        if let info = Bundle.main.infoDictionary {
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown version"
            sessionConfig.httpAdditionalHeaders = [
                "User-Agent": "Share As Post Extension \(appVersion)"
            ]
        }
        return URLSession(configuration: sessionConfig)
    }()
}

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
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        return defaults?.string(forKey: "defaultUrl") != nil
    }
    
    func uploadImage(imageData : Data, encodingCompletion : (() -> Void)?) {
        let request = self.createRequest(imageData: imageData, parameters: nil)
        let task = BackgroundUploader.shared.session.uploadTask(withStreamedRequest: request)
        task.resume()
        encodingCompletion?()
    }
    
    func logErrorAndCompleteRequest(error: Error?) {
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func didSelectPost() {
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { self.logErrorAndCompleteRequest(error: nil); return }
        if items.count == 0 { self.logErrorAndCompleteRequest(error: nil); return }
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
                            self.uploadImage(imageData: imageData, encodingCompletion: {
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            })
                        })
                    } else {
                        attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (decoder, error) in
                            if error != nil { self.logErrorAndCompleteRequest(error: error); return }
                            
                            if let url = decoder as? URL {
                                guard let imageData = NSData.init(contentsOf: url) as Data? else {
                                    self.logErrorAndCompleteRequest(error: error); return }
                                self.uploadImage(imageData: imageData, encodingCompletion: {
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                })
                            } else if let image = decoder as? UIImage {
                                guard let imageData = UIImageJPEGRepresentation(image, 1) else {
                                    self.logErrorAndCompleteRequest(error: error); return }
                                self.uploadImage(imageData: imageData, encodingCompletion: {
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
                        let request = self.createRequest(imageData: nil, parameters: parameters)
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
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
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
    
    /// Create request
    ///
    /// - parameter userid:   The userid to be passed to web service
    /// - parameter password: The password to be passed to web service
    /// - parameter email:    The email address to be passed to web service
    ///
    /// - returns:            The NSURLRequest that was created
    
    func createRequest(imageData: Data?, parameters: [String: String]?) -> URLRequest {
        let boundary = generateBoundaryString()
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        
        var request = URLRequest(url: URL(string: (defaults?.string(forKey: "defaultUrl"))!)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var additionalParameters = defaults?.dictionary(forKey: "additionalParams") as? [String : String] ?? [:]
        if imageData != nil {
            additionalParameters["caption"] = self.contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if parameters != nil {
            additionalParameters.merge(parameters!, uniquingKeysWith: { (key1, key2) -> String in
                parameters![key2]!
            })
        }
        request.httpBody = createBody(with: additionalParameters, imageData: imageData, boundary: boundary)
        
        return request
    }
    
    /// Create body of the multipart/form-data request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The multipart/form-data boundary
    ///
    /// - returns:                The NSData of the body of the request
    
    func createBody(with parameters: [String: String]?, imageData: Data?, boundary: String) -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        if imageData != nil {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"image\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData!)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// - parameter path:         The path of the file for which we are going to determine the mime type.
    ///
    /// - returns:                Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    
    func mimeType(for path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
}

extension Data {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
