//
//  RAMLExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation
import RAML
import ChickGen

public extension RAML {
    
    public func swiftResourceClientClassName() -> String {
        return "\(title.swiftClassName())Client"
    }
    
    public func swiftResourceServerClassName() -> String {
        return "\(title.swiftClassName())Server"
    }
    
    public func swiftClientFunctionNameFor(method: ResourceMethod,
                                           inResource resource: Resource) -> String {
        var pathComponent = absolutePathForResource(resource)
        pathComponent = pathComponent.replacingOccurrences(of: "/", with: "")
        pathComponent = pathComponent.capitalizingFirstLetter()
        
        pathComponent = pathComponent.replacingParams { paramName -> (String) in
            return "With\(paramName.capitalizingFirstLetter())"
        }
        
        var methodComponent = method.type.rawValue
        methodComponent = methodComponent.lowercased()
        
        return "\(methodComponent)\(pathComponent)"
    }
    
    public func vaporFunctionNameFor(method: ResourceMethod,
                                     inResource resource: Resource) -> String {
        var pathComponent = absolutePathForResource(resource)
        pathComponent = pathComponent.replacingOccurrences(of: "/", with: "")
        pathComponent = pathComponent.capitalizingFirstLetter()
        
        pathComponent = pathComponent.replacingParams { paramName -> (String) in
            return "With\(paramName.capitalizingFirstLetter())"
        }
        
        var methodComponent = method.type.rawValue
        methodComponent = methodComponent.lowercased()
        
        return "\(methodComponent)\(pathComponent)"
    }
    
    public func swiftClientFunctionParametersFor(method: ResourceMethod,
                                                 inResource resource: Resource) -> [Settings.Class.FunctionParameter] {
        var parameters: [Settings.Class.FunctionParameter] = []
        parameters.append(contentsOf: swiftClientFunctionURIParametersFor(resource: resource))
        parameters.append(contentsOf: swiftClientFunctionBodyParametersFor(method: method))
        return parameters
    }
    
    public func swiftClientFunctionURIParametersFor(resource: Resource) -> [Settings.Class.FunctionParameter] {
        var parameters: [Settings.Class.FunctionParameter] = []
        for uriParameter in resource.uriParameters ?? [] {
            guard let type = uriParameter.type else { continue }
            let typeString = type.swiftClassName() + ((uriParameter.required ?? true) ? "" : "?")
            let param = Settings.Class.FunctionParameter(name: uriParameter.identifier, type: typeString)
            parameters.append(param)
        }
        return parameters
    }
    
    public func swiftClientFunctionBodyParametersFor(method: ResourceMethod) -> [Settings.Class.FunctionParameter] {
        guard let bodyType = method.body?.type else {
            return []
        }
        return [
            Settings.Class.FunctionParameter(name: "body", type: bodyType.swiftType())
        ]
    }
    
}
