//
//  ConfigureViewController.swift
//  DeveloperExcuses
//
//  Created by Bob Sun on 2020/2/8.
//  Copyright © 2020 Marcus Kida. All rights reserved.
//

import Cocoa
import ScreenSaver

class ConfigureViewController: NSObject {
    
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var interval: NSTextField!
    
    
    override init() {
        super.init()
        let bundle = Bundle(for: ConfigureViewController.self)
        bundle.loadNibNamed("ConfigureViewController", owner: self, topLevelObjects: nil)
        interval.stringValue = "\(DefaultsManager.fetchInterval)"
        interval.formatter = IntervalFormatter()
    }
    
    @IBAction func selectVideo(_ sender: Any) {
        let url = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Movies").appendingPathComponent("LiveDevEx")
        if !FileManager.default.fileExists(atPath: url.absoluteString) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: [:])
            } catch {
                NSLog(error.localizedDescription)
            }
        }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    @IBAction func onClose(_ sender: Any) {
        let value = (interval.stringValue as NSString).intValue
        DefaultsManager.fetchInterval = Int(value > 0 ? value : 15)
        window.endSheet(window)
    }
}
