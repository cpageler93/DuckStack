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
        var attributes: [Settings.Class.Attribute] = []
        
        if let version = raml.version {
            let versionAttribute = Settings.Class.Attribute(ref: .let, name: "version", type: "String", optional: false)
            versionAttribute.defaultValue = "\"\(version)\""
            attributes.append(versionAttribute)
        }
        
        functions.append(contentsOf: generateClientInitFunctions())
        functions.append(contentsOf: try generateFunctionsForResources())
        
        
        let resourceClass = Settings.Class(name: raml.swiftResourceClientClassName(),
                                           attributes: attributes,
                                           functions: functions)
        resourceClass.superclass = "QuackClient"
        resourceClass.imports = [
            "Foundation",
            "Quack"
        ]
        settings.classes.append(resourceClass)
    }
    
    private func generateFunctionsForResources() throws -> [Settings.Class.Function] {
        var functions: [Settings.Class.Function] = []
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
        return functions
    }
    
    private func generateFunctionsFor(resource: Resource) throws -> [Settings.Class.Function] {
        var functions: [Settings.Class.Function] = []
        
        if let resourceOfType = resource.resourceOfType() {
            let newFunctions = try resourceFunctionsFor(resource: resource, withType: resourceOfType)
            functions.append(contentsOf: newFunctions)
        } else {
            for method in resource.methods ?? [] {
                let newFunctions = try nonResourceFunctionsForMethod(method, inResource: resource)
                functions.append(contentsOf: newFunctions)
            }
        }
        return functions
    }
    
    private func nonResourceFunctionsForMethod(_ method: ResourceMethod, inResource resource: Resource) throws -> [Settings.Class.Function] {
        guard let validResponse = method.validResponse() else {
            throw DuckStackError.noValidResponseFor(method: method)
        }
        guard let validResponseType = validResponse.body?.type else {
            throw DuckStackError.noValidBodyTypeInResponseFor(method: method)
        }
        
        let syncFunction = try syncResourceFunction(method: method,
                                                    resource: resource,
                                                    response: validResponse,
                                                    responseType: validResponseType)
        
        let asyncFunction = try asyncResourceFunction(method: method,
                                                      resource: resource,
                                                      response: validResponse,
                                                      responseType: validResponseType)
        
        return [syncFunction, asyncFunction]
    }
    
    private func resourceFunctionsFor(resource: Resource, withType: String) throws -> [Settings.Class.Function] {
        var functions: [Settings.Class.Function] = []
        
        let singleItemResource = resource.addSingleItemResource()
        
        let getList = resource.resourceMethodForGetList(inRaml: raml, withType: withType)
        functions.append(contentsOf: try nonResourceFunctionsForMethod(getList, inResource: resource))
        
        let postItem = resource.resourceMethodForPostItem(inRaml: raml, withType: withType)
        functions.append(contentsOf: try nonResourceFunctionsForMethod(postItem, inResource: resource))
        
        let getSingleItem = singleItemResource.resourceMethodForGetSingleItem(inRaml: raml, withType: withType)
        functions.append(contentsOf: try nonResourceFunctionsForMethod(getSingleItem, inResource: singleItemResource))
        
        let patchSingleItem = singleItemResource.resourceMethodForPatchSingleItem(inRaml: raml, withType: withType)
        functions.append(contentsOf: try nonResourceFunctionsForMethod(patchSingleItem, inResource: singleItemResource))
        
        let deleteSingleItem = singleItemResource.resourceMethodForDeleteSingleItem(inRaml: raml, withType: withType)
        functions.append(contentsOf: try nonResourceFunctionsForMethod(deleteSingleItem, inResource: singleItemResource))
        
        return functions
    }
    
    private func generateClientInitFunctions() -> [Settings.Class.Function] {
        guard let baseURI = raml.baseURI else { return [] }
        
        var baseURIString = baseURI.value
        baseURIString = baseURIString.replacingParams { paramName -> (String) in
            return "\\(\(paramName))"
        }
        
        var initLines: [String] = []
        initLines.append(contentsOf: [
            "super.init(url: URL(string: \"\(baseURIString)\")!)"
        ])
        
        var parameters: [Settings.Class.FunctionParameter] = []
        
        if let baseURIParameters = raml.baseURIParameters {
            for baseURIParameter in baseURIParameters {
                guard let type = baseURIParameter.type else { continue }
                let parameter = Settings.Class.FunctionParameter(name: baseURIParameter.identifier,
                                                                 type: type.swiftClassName())
                parameter.optional = false
                parameters.append(parameter)
            }
        }
        
        let initFunction = Settings.Class.Function(name: "init",
                                                   parameters: parameters,
                                                   bodyLines: initLines)
        
        return [initFunction]
    }
    
    
}
