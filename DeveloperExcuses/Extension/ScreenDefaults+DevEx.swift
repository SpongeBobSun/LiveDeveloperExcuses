//
//  UserDefaults+DevEx.swift
//  DeveloperExcuses
//
//  Created by Bob Sun on 2020/2/9.
//  Copyright © 2020 Marcus Kida. All rights reserved.
//

import Foundation
import ScreenSaver

extension UserDefaults {
    
    static var backVideo: String? {
        get {
            return UserDefaults.standard.string(forKey: "backVideo")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "backVideo")
            UserDefaults.standard.synchronize()
        }
    }
}
