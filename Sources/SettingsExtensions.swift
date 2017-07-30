//
//  SettingsExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 30.07.17.
//

import Foundation
import ChickGen

public extension Settings {
    
    public func clear() {
        self.classes = []
        self.enums = []
        self.extensions = []
    }
    
}
