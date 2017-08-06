//
//  ResourceExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 06.08.17.
//

import Foundation
import RAML

public extension Resource {
    
    public func vaporRoutePathName() -> String? {
        var routePath = self.path
        routePath = routePath.replacingParams { _ in "" }
        routePath = routePath.withRemovedPrefix("/")
        routePath = routePath.withRemovedSuffix("/")
        
        if routePath.characters.count > 0 {
            return routePath
        } else {
            return nil
        }
    }
    
    public func vaporRoutePathParams() -> String {
        var params: [String] = []
        params.append("\"/\"")
        for uriParameter in uriParameters ?? [] {
            params.append("\":\(uriParameter.identifier)\"")
        }
        return params.joined(separator: ", ")
    }

    
}
