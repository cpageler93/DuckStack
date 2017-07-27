//
//  PropertyExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 27.07.17.
//

import Foundation
import RAML

public extension Property {
    
    public func swiftOptional() -> Bool {
        return !(required ?? true) || hasAnnotationWith(name: "primaryKey")
    }
    
}
