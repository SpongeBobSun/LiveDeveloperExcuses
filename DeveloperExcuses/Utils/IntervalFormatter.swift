//
//  IntervalFormatter.swift
//  LiveDeveloperExcuses
//
//  Created by Bob Sun on 2020/2/10.
//  Copyright © 2020 Marcus Kida. All rights reserved.
//

import Foundation
import AppKit

open class IntervalFormatter: NumberFormatter {
    override open func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if partialString.count == 0 {
            return true
        }
        let scanner = Scanner(string: partialString)
        
        if(!(scanner.scanInt(nil) && scanner.isAtEnd)) {
            NSSound.beep()
            return false;
        }

        return true;
    }
}
