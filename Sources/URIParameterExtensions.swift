//
//  URIParameterExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation
import RAML

public extension URIParameter.ParameterType {
    
    public func swiftClassName() -> String {
        return self.rawValue.capitalizingFirstLetter()
    }
    
}
