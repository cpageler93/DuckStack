//
//  ResourceGenerator.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation
import RAML
import ChickGen

public class ResourceGenerator {
    
    public let raml: RAML
    
    public init(raml: RAML) {
        self.raml = raml
    }
    
    public func generateFor(settings: inout Settings) {
        var functions: [Settings.Class.Function] = []
        raml.enumerateResource { resource, _, _ in
            let newFunctions = self.generateFunctionsFor(resource: resource)
            functions.append(contentsOf: newFunctions)
        }
        
        let resourceClass = Settings.Class(name: raml.swiftResourceClassName(),
                                           attributes: [],
                                           functions:functions)
        resourceClass.superclass = "QuackClient"
        resourceClass.imports = [
            "Foundation",
            "Quack"
        ]
        settings.classes.append(resourceClass)
    }
    
    private func generateFunctionsFor(resource: Resource) -> [Settings.Class.Function] {
        var functions: [Settings.Class.Function] = []
        for method in resource.methods ?? [] {
            let newFunction = functionForMethod(method, inResource: resource)
            functions.append(newFunction)
        }
        return functions
    }
    
    private func functionForMethod(_ method: ResourceMethod, inResource resource: Resource) -> Settings.Class.Function {
        let functionName = swiftFunctionNameFor(method: method, inResource: resource)
        var bodyLines: [String] = []
        var returnType = ""
        
        if let validResponse = method.responseWith(code: 200) ?? method.responseWith(code: 201) {
            if let validResponseType = validResponse.body?.type {
                
                // determine return type
                switch validResponseType {
                case .any:
                    returnType = "QuackVoid"
                default:
                    returnType = "QuackResult<\(validResponseType.swiftType())>"
                }
                
                // determine body lines
                switch validResponseType {
                case .array(let type):
                    bodyLines = [
                        "return respondWithArray(method: .\(method.type.rawValue),",
                        "                        path: \"\(raml.absolutePathForResource(resource))\",",
                        "                        model: \(type.swiftType()).self)"
                    ]
                default:
                    bodyLines = [
                        "// code lines for request"
                    ]
                }
            }
        }
        
        let newFunction = Settings.Class.Function(name: functionName,
                                                  parameters: [],
                                                  bodyLines: bodyLines)
        newFunction.returnType = returnType
        
        return newFunction
    }
    
    private func swiftFunctionNameFor(method: ResourceMethod, inResource resource: Resource) -> String {
        var pathComponent = raml.absolutePathForResource(resource)
        pathComponent = pathComponent.replacingOccurrences(of: "/", with: "")
        pathComponent = pathComponent.capitalizingFirstLetter()
        
        var methodComponent = method.type.rawValue
        methodComponent = methodComponent.lowercased()
        
        return "\(methodComponent)\(pathComponent)"
    }
    
}
