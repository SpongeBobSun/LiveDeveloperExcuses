//
//  DefaultsManager.swift
//  LiveDeveloperExcuses
//
//  Created by Bob Sun on 2020/2/9.
//  Copyright © 2020 Marcus Kida. All rights reserved.
//

import ScreenSaver

class DefaultsManager {

    static var defaults = ScreenSaverDefaults.init(forModuleWithName: Bundle(for: DefaultsManager.self).bundleIdentifier!)!
    
    func setColor(_ color: NSColor, key: String) {
        let defaults = DefaultsManager.defaults
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: color), forKey: key)
        defaults.synchronize()
    }

    func getColor(_ key: String) -> NSColor? {
        let defaults = DefaultsManager.defaults
        if let canvasColorData = defaults.object(forKey: key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: canvasColorData) as? NSColor
        }
        return nil;
    }
    
    static var fetchInterval: Int {
        get {
            let defaults = DefaultsManager.defaults
            let ret = defaults.integer(forKey: "fetchInterval")
            if ret <= 0 {
                return 15
            }
            return ret
        }
        set {
            let defaults = DefaultsManager.defaults
            defaults.set(newValue, forKey: "fetchInterval")
            defaults.synchronize()
        }
    }
        
}
