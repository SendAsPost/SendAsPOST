//
//  SharedDefaults.swift
//  SendAsPostMacShareExtension
//
//  Created by Andy Brett on 12/9/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Foundation

extension UserDefaults {
    static func shared() -> UserDefaults? {
        let prefix = Bundle.main.infoDictionary?["TeamIdentifierPrefix"] as? String ?? ""
        return UserDefaults(suiteName: "\(prefix)group.sendaspost.sendaspost")
    }
}
