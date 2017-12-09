//
//  BackgroundUploader.swift
//  SendAsPostMacShareExtension
//
//  Created by Andy Brett on 12/9/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Foundation

struct BackgroundUploader {
    
    static let shared = BackgroundUploader()
    
    let session: URLSession = {
        let configName = "com.sendaspost.background"
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: configName)
        var prefix = ""
        if let info = Bundle.main.infoDictionary {
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown version"
            sessionConfig.httpAdditionalHeaders = [
                "User-Agent": "Send As POST Extension \(appVersion)"
            ]
            prefix = info["TeamIdentifierPrefix"] as? String ?? ""
        }
        sessionConfig.sharedContainerIdentifier = "\(prefix)group.sendaspost.sendaspost"
        return URLSession(configuration: sessionConfig)
    }()
}
