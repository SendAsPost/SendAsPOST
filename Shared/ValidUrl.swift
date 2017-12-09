//
//  ValidUrl.swift
//  SendAsPostMacShareExtension
//
//  Created by Andy Brett on 12/9/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Foundation

extension String {
    func validUrl() -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_:])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: self)
    }
}
