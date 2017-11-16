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

    override func viewDidLoad() {
        self.placeholder = "Caption"
    }
    
    override func isContentValid() -> Bool {
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        return defaults?.string(forKey: "defaultUrl") != nil
    }
    
    func uploadImage(imageData : Data, encodingCompletion : (() -> Void)?) {
        do {
            let request = try self.createRequest(imageData: imageData)
            let task = BackgroundUploader.shared.session.uploadTask(withStreamedRequest: request)
            task.resume()
        } catch {
            //
        }
        encodingCompletion?()
    }
    
    override func didSelectPost() {
        guard let items = self.extensionContext?.inputItems as? [NSExtensionItem] else { return }

        for item in items {
            guard let attachments = item.attachments as? [NSItemProvider] else { continue }
            for attachment in attachments {
                if attachment.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    if #available(iOSApplicationExtension 11.0, *) {
                        attachment.loadFileRepresentation(forTypeIdentifier: kUTTypeImage as String, completionHandler: { (url, error) in
                            if url == nil || error != nil { return }
                            guard let imageData = NSData.init(contentsOf: url!) as Data? else { return }
                            self.uploadImage(imageData: imageData, encodingCompletion: {
                                self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                            })
                        })
                    } else {
                        attachment.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (decoder, error) in
                            if error != nil { return }
                            
                            if let url = decoder as? URL {
                                guard let imageData = NSData.init(contentsOf: url) as Data? else { return }
                                self.uploadImage(imageData: imageData, encodingCompletion: {
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                })
                            } else if let image = decoder as? UIImage {
                                guard let imageData = UIImageJPEGRepresentation(image, 1) else { return }
                                self.uploadImage(imageData: imageData, encodingCompletion: {
                                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                                })
                            }
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
    
    /// Create request
    ///
    /// - parameter userid:   The userid to be passed to web service
    /// - parameter password: The password to be passed to web service
    /// - parameter email:    The email address to be passed to web service
    ///
    /// - returns:            The NSURLRequest that was created
    
    func createRequest(imageData: Data) throws -> URLRequest {
        let boundary = generateBoundaryString()
        let defaults = UserDefaults(suiteName: "group.sendaspost.sendaspost")
        
        var request = URLRequest(url: URL(string: (defaults?.string(forKey: "defaultUrl"))!)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var parameters = defaults?.dictionary(forKey: "additionalParams") as? [String : String] ?? [:]
        parameters["caption"] = self.contentText.trimmingCharacters(in: .whitespacesAndNewlines)
        request.httpBody = try createBody(with: parameters, imageData: imageData, boundary: boundary)
        
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
    
    func createBody(with parameters: [String: String]?, imageData: Data, boundary: String) throws -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
            
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n")
        
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
