//
//  RAMLExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation
import RAML

public extension RAML {
    
    public func swiftResourceClassName() -> String {
        return "\(title.swiftClassName())Client"
    }
    
}
