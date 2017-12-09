//
//  AppDelegate.swift
//  SendAsPostMac
//
//  Created by Andy Brett on 12/7/17.
//  Copyright © 2017 APB. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func aboutPressed(_ sender: Any) {
        if #available(OSX 10.13, *) {
            NSApplication.shared.orderFrontStandardAboutPanel(options: [NSApplication.AboutPanelOptionKey.credits : NSAttributedString(string: "Pigeon Post icon by Intro Mike, from thenounproject.com"), NSApplication.AboutPanelOptionKey.applicationName : "Send As POST"])
        } else {
            NSApplication.shared.orderFrontStandardAboutPanel(options: [:])
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

