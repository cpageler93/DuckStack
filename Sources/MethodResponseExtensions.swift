//
//  MethodResponseExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation
import RAML

public extension ResourceMethod {
    
    public func validResponse() -> MethodResponse? {
        return responseWith(code: 200) ?? responseWith(code: 201)
    }
    
}
