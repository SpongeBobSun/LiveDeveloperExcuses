//
//  DefaultsManager.swift
//  LiveDeveloperExcuses
//
//  Created by Bob Sun on 2020/2/9.
//  Copyright © 2020 Marcus Kida. All rights reserved.
//

import ScreenSaver

class DefaultsManager {
    
    var defaults: UserDefaults
    
    init() {
        let identifier = Bundle(for: DefaultsManager.self).bundleIdentifier
        defaults = ScreenSaverDefaults.init(forModuleWithName: identifier!)!
    }
    
    func setColor(_ color: NSColor, key: String) {
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: color), forKey: key)
        defaults.synchronize()
    }

    func getColor(_ key: String) -> NSColor? {
        if let canvasColorData = defaults.object(forKey: key) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: canvasColorData) as? NSColor
        }
        return nil;
    }
        
}
