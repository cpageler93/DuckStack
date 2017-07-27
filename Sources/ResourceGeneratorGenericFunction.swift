//
//  ResourceGeneratorGenericFunction.swift
//  DuckStack
//
//  Created by Christoph Pageler on 27.07.17.
//

import Foundation
import RAML
import ChickGen

public extension ResourceGenerator {
    
    public func swiftFunctionParameterFor(method: ResourceMethod) -> String {
        return "method: .\(method.type.rawValue)"
    }
    
    public func swiftFunctionParameterFor(path fromResource: Resource) -> String {
        let path = raml.absolutePathForResource(fromResource).replacingParams { paramName -> (String) in
            return "\\(\(paramName))"
        }
        return "path: \"\(path)\""
    }
    
    public func swiftFunctionParameterFor(model withType: DataType) -> String {
        return "model: \(withType.swiftType()).self"
    }
    
    public func swiftFunctionParameterForCompletion() -> String {
        return "completion: completion"
    }
    
    public func swiftFunctionParamsPreperation(method: ResourceMethod) -> [String] {
        let parameters = raml.swiftFunctionBodyParametersFor(method: method)
        if parameters.count > 0 {
            var lines: [String] = [
                "var map: [String: QuackModel] = [:]"
            ]
            
            for parameter in parameters {
                lines.append(contentsOf: [
                    "map[\"\(parameter.name)\"] = \(parameter.name)"
                ])
            }
            
            lines.append(contentsOf: [
                "let preparedParams = preparedParamsWith(map)",
                ""
            ])
            
            return lines
        } else {
            return []
        }
    }
    
    public func swiftFunctionParameterForParams(method: ResourceMethod) -> String {
        let parameters = raml.swiftFunctionBodyParametersFor(method: method)
        if parameters.count > 0 {
            return "params: preparedParams"
        } else {
            return "// no params"
        }
    }
    
}
