//
//  Requests.swift
//  SendAsPostMacShareExtension
//
//  Created by Andy Brett on 12/9/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Foundation

class RequestManager {
    
    static func uploadImage(imageData : Data, parameters: [String : String]?, encodingCompletion : (() -> Void)?) {
        let request = self.createRequest(imageData: imageData, parameters: parameters)
        let task = BackgroundUploader.shared.session.uploadTask(withStreamedRequest: request)
        task.resume()
        encodingCompletion?()
    }
    
    /// Create request
    ///
    /// - parameter userid:   The userid to be passed to web service
    /// - parameter password: The password to be passed to web service
    /// - parameter email:    The email address to be passed to web service
    ///
    /// - returns:            The NSURLRequest that was created

    static func createRequest(imageData: Data?, parameters: [String: String]?) -> URLRequest {
        let boundary = RequestManager.generateBoundaryString()
        let defaults: UserDefaults = UserDefaults.shared() ?? UserDefaults.standard
        
        var request = URLRequest(url: URL(string: (defaults.string(forKey: "defaultUrl"))!)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        var additionalParameters = defaults.dictionary(forKey: "additionalParams") as? [String : String] ?? [:]
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

    static func createBody(with parameters: [String: String]?, imageData: Data?, boundary: String) -> Data {
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

    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// - parameter path:         The path of the file for which we are going to determine the mime type.
    ///
    /// - returns:                Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.

//    func mimeType(for path: String) -> String {
//        let url = NSURL(fileURLWithPath: path)
//        let pathExtension = url.pathExtension
//
//        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
//            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
//                return mimetype as String
//            }
//        }
//        return "application/octet-stream";
//    }
}
