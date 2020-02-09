//
//  AppDelegate.swift
//  DeveloperExcusesDebug
//
//  Created by Marcus Kida on 08.06.17.
//  Copyright © 2017 Marcus Kida. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var screenSaverView = DeveloperExcusesView(frame: .zero, isPreview: false)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard
            let window = NSApplication.shared.mainWindow,
            let screenSaverView = screenSaverView
        else {
            preconditionFailure()
        }
        let vc =  NSStoryboard(name: "Main", bundle: Bundle.main).instantiateController(withIdentifier: "debugVC") as! DebugViewController
        window.contentViewController = vc
        screenSaverView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
        screenSaverView.autoresizingMask = [.height, .width]
        vc.view.addSubview(screenSaverView, positioned: .below, relativeTo: vc.view)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

