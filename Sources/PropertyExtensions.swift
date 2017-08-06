//
//  PropertyExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 27.07.17.
//

import Foundation
import RAML

public extension Property {
    
    public func swiftIsOptional() -> Bool {
        return !(required ?? true) || isPrimaryKey()
    }
    
    public func isPrimaryKey() -> Bool {
        return hasAnnotationWith(name: "primaryKey")
    }
    
}
