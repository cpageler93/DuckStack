//
//  ResourceGeneratorAsyncFunction.swift
//  DuckStack
//
//  Created by Christoph Pageler on 27.07.17.
//

import Foundation
import RAML
import ChickGen

public extension ResourceGenerator {
    
    public func asyncResourceFunction(method: ResourceMethod,
                                     resource: Resource,
                                     response: MethodResponse,
                                     responseType: DataType) throws -> Settings.Class.Function {
        
        let bodyLines = swiftFunctionBodyLinesForMethod(method, inResource: resource, forResponseType: responseType)
        var parameters = raml.swiftFunctionParametersFor(method: method, inResource: resource)
        parameters.append(Settings.Class.FunctionParameter(name: "completion", type: "@escaping (\(responseType.quackReturnValue()) -> ()"))
        let functionName = raml.swiftFunctionNameFor(method: method, inResource: resource)
        
        let asyncFunction = Settings.Class.Function(name: functionName,
                                                    parameters: parameters,
                                                    bodyLines: bodyLines)
        asyncFunction.returnType = responseType.quackVoidReturnValue()
        
        return asyncFunction
    }
    
    private func swiftFunctionBodyLinesForMethod(_ method: ResourceMethod,
                                                 inResource resource: Resource,
                                                 forResponseType responseType: DataType) -> [String] {
        var bodyLines: [String] = []
        bodyLines.append(contentsOf: swiftFunctionParamsPreperation(method: method))
        
        switch responseType {
        case .array(let type):
            bodyLines.append(contentsOf: [
                "return respondWithArrayAsync(\(swiftFunctionParameterFor(method: method)),",
                "                             \(swiftFunctionParameterFor(path: resource)),",
                "                             \(swiftFunctionParameterForParams(method: method)),",
                "                             \(swiftFunctionParameterFor(model: type)),",
                "                             \(swiftFunctionParameterForCompletion()))"
            ])
        default:
            bodyLines.append(contentsOf: [
                "return respondAsync(\(swiftFunctionParameterFor(method: method)),",
                "                    \(swiftFunctionParameterFor(path: resource)),",
                "                    \(swiftFunctionParameterForParams(method: method)),",
                "                    \(swiftFunctionParameterFor(model: responseType)),",
                "                    \(swiftFunctionParameterForCompletion()))"
            ])
        }
        
        return bodyLines.filter { !$0.contains("// no") }
    }
    
}
