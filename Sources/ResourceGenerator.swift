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
    
    public func generateFor(settings: inout Settings) throws {
        var functions: [Settings.Class.Function] = []
        
        // enumerate resources for generation
        var errorInResourceEnumeration: Error? = nil
        raml.enumerateResource { resource, _, stop in
            do {
                let newFunctions = try self.generateFunctionsFor(resource: resource)
                functions.append(contentsOf: newFunctions)
            } catch {
                errorInResourceEnumeration = error
                stop = true
            }
        }
        if let errorInResourceEnumeration = errorInResourceEnumeration {
            throw errorInResourceEnumeration
        }
        
        // create single "Resource"-Class
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
    
    private func generateFunctionsFor(resource: Resource) throws -> [Settings.Class.Function] {
        var functions: [Settings.Class.Function] = []
        for method in resource.methods ?? [] {
            let newFunction = try functionForMethod(method, inResource: resource)
            functions.append(newFunction)
        }
        return functions
    }
    
    private func functionForMethod(_ method: ResourceMethod, inResource resource: Resource) throws -> Settings.Class.Function {
        guard let validResponse = method.validResponse() else {
            throw DuckStackError.noValidResponseFor(method: method)
        }
        guard let validResponseType = validResponse.body?.type else {
            throw DuckStackError.noValidBodyTypeInResponseFor(method: method)
        }
        
        // determine body lines
        var bodyLines: [String] = []
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
        
        // determine function parameters
        var parameters: [Settings.Class.FunctionParameter] = []
        
        // uri parameter
        for uriParameter in resource.uriParameters ?? [] {
            guard let type = uriParameter.type else { continue }
            let typeString = type.swiftClassName() + ((uriParameter.required ?? true) ? "" : "?")
            let param = Settings.Class.FunctionParameter(name: uriParameter.identifier, type: typeString)
            parameters.append(param)
        }
        
        // body parameter
        if let bodyType = method.body?.type {
            let bodyParameter = Settings.Class.FunctionParameter(name: "body", type: bodyType.swiftType())
            parameters.append(bodyParameter)
        }
        
        let newFunction = Settings.Class.Function(name: swiftFunctionNameFor(method: method, inResource: resource),
                                                  parameters: parameters,
                                                  bodyLines: bodyLines)
        newFunction.returnType = validResponseType.quackReturnValue()
        
        return newFunction
    }
    
    private func swiftFunctionNameFor(method: ResourceMethod, inResource resource: Resource) -> String {
        var pathComponent = raml.absolutePathForResource(resource)
        pathComponent = pathComponent.replacingOccurrences(of: "/", with: "")
        pathComponent = pathComponent.capitalizingFirstLetter()
        
        // replace parameters in Path
        do {
            let parameterRegex = try NSRegularExpression(pattern: "\\{(.*)\\}")
            var parameterMatches: [NSTextCheckingResult] = []
            repeat {
                parameterMatches = parameterRegex.matches(in: pathComponent, options: [], range: NSMakeRange(0, pathComponent.characters.count))
                guard let firstMatch = parameterMatches.first else { break }
                let bigRange = firstMatch.rangeAt(0)
                let smallRange = firstMatch.rangeAt(1)
                
                let nsPathComponent = pathComponent as NSString
                let parameterName = nsPathComponent.substring(with: smallRange).capitalizingFirstLetter()
                pathComponent = nsPathComponent.replacingCharacters(in: bigRange, with: "With\(parameterName)")
                
            } while(parameterMatches.count > 0)
            
        } catch {
            
        }
        
        var methodComponent = method.type.rawValue
        methodComponent = methodComponent.lowercased()
        
        return "\(methodComponent)\(pathComponent)"
    }
    
}
