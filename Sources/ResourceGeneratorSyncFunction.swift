//
//  ResourceGeneratorSyncFunction.swift
//  DuckStack
//
//  Created by Christoph Pageler on 27.07.17.
//

import Foundation
import RAML
import ChickGen

public extension ResourceGenerator {
    
    public func syncResourceFunction(method: ResourceMethod,
                                     resource: Resource,
                                     response: MethodResponse,
                                     responseType: DataType) throws -> Settings.Class.Function {
        
        let bodyLines = swiftFunctionBodyLinesForMethod(method, inResource: resource, forResponseType: responseType)
        let parameters = raml.swiftFunctionParametersFor(method: method, inResource: resource)
        let functionName = raml.swiftFunctionNameFor(method: method, inResource: resource)
        
        let syncFunction = Settings.Class.Function(name: functionName,
                                                   parameters: parameters,
                                                   bodyLines: bodyLines)
        syncFunction.returnType = responseType.quackReturnValue()
        
        return syncFunction
    }
    
    private func swiftFunctionBodyLinesForMethod(_ method: ResourceMethod,
                                                 inResource resource: Resource,
                                                 forResponseType responseType: DataType) -> [String] {
        var bodyLines: [String] = []
        bodyLines.append(contentsOf: swiftFunctionParamsPreperation(method: method))
        
        switch responseType {
        case .array(let type):
            bodyLines.append(contentsOf: [
                "return respondWithArray(\(swiftFunctionParameterFor(method: method)),",
                "                        \(swiftFunctionParameterFor(path: resource)),",
                "                        \(swiftFunctionParameterForParams(method: method)),",
                "                        \(swiftFunctionParameterFor(model: type)))"
            ])
        default:
            bodyLines.append(contentsOf: [
                "return respond(\(swiftFunctionParameterFor(method: method)),",
                "               \(swiftFunctionParameterFor(path: resource)),",
                "               \(swiftFunctionParameterForParams(method: method)),",
                "               \(swiftFunctionParameterFor(model: responseType)))"
            ])
        }
        
        return bodyLines.filter { !$0.contains("// no") }
    }
    
}
