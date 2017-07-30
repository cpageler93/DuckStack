//
//  ServerGeneratorModelExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 30.07.17.
//

import Foundation
import RAML
import PathKit
import ChickGen

public extension ServerGenerator {
    
    internal func generateVaporModelExtensionsFor(type: Type) throws -> [Settings.Extension] {
        return [
            try generateVaporModelPreperationExtension(forType: type),
            try generateVaporModelJSONConvertibleExtension(forType: type),
            try generateVaporModelResponseRepresentableExtension(forType: type),
            try generateVaporModelUpdateableExtension(forType: type)
        ]
    }
    
    private func generateVaporModelPreperationExtension(forType type: Type) throws -> Settings.Extension {
        let preperationExtension = Settings.Extension(name: type.name)
        preperationExtension.inheritance = "Preparation"
        preperationExtension.filename = "\(type.name)Preperation"
        preperationExtension.accessControl = ""
        preperationExtension.imports = [
            "Vapor",
            "FluentProvider"
        ]
        
        
        
        
        
        var prepareFunctionBodyLines: [String] = [
            "try database.create(self) { builder in"
        ]
        
        for property in type.properties ?? [] {
            guard let propertyType = property.type else { continue }
            let vaporBuilderType = propertyType.swiftType().lowercased()
            let line = "   builder.\(vaporBuilderType)(\(type.name).\(property.name)Key)"
            prepareFunctionBodyLines.append(line)
        }
        
        prepareFunctionBodyLines.append(contentsOf: [
            "}"
        ])
        
        let prepareFunctionDatabaseParam = Settings.Class.FunctionParameter(name: "database", type: "Database")
        prepareFunctionDatabaseParam.label = "_"
        let prepareFunction = Settings.Class.Function(name: "prepare",
                                                      parameters: [prepareFunctionDatabaseParam],
                                                      bodyLines: prepareFunctionBodyLines)
        prepareFunction.throws = true
        prepareFunction.accessControl = "static"
        
        
        
        
        let revertFunctionDatabaseParam = Settings.Class.FunctionParameter(name: "database", type: "Database")
        revertFunctionDatabaseParam.label = "_"
        let revertFunction = Settings.Class.Function(name: "revert", parameters: [revertFunctionDatabaseParam], bodyLines: [
            "try database.delete(self)"
        ])
        revertFunction.throws = true
        revertFunction.accessControl = "static"
        
        
        
        preperationExtension.functions = [
            prepareFunction,
            revertFunction
        ]
        
        return preperationExtension
    }
    
    private func generateVaporModelJSONConvertibleExtension(forType type: Type) throws -> Settings.Extension {
        
        var jsonInitFunctionBodyLines: [String] = [
            "try self.init("
        ]
        for property in type.properties ?? [] {
            if property.swiftOptional() { continue }
            jsonInitFunctionBodyLines.append(contentsOf: [
                "    \(property.name): json.get(\(type.name).\(property.name)Key)"
            ])
            
        }
        jsonInitFunctionBodyLines.append(contentsOf: [
            ")"
        ])
        
        let jsonInitFunctionParams = [
            Settings.Class.FunctionParameter(name: "json", type: "JSON")
        ]
        let jsonInitFunction = Settings.Class.Function(name: "init",
                                                       parameters: jsonInitFunctionParams,
                                                       bodyLines: jsonInitFunctionBodyLines)
        jsonInitFunction.accessControl = "convenience"
        jsonInitFunction.throws = true
        
        var makeJsonFunctionBodyLines: [String] = [
            "var json = JSON()"
        ]
        
        for property in type.properties ?? [] {
            makeJsonFunctionBodyLines.append(contentsOf: [
                "try json.set(\(type.name).\(property.name)Key, \(property.name))"
            ])
        }
        makeJsonFunctionBodyLines.append(contentsOf: [
            "return json"
        ])
        
        let jsonMakeJSONFunction = Settings.Class.Function(name: "makeJSON", bodyLines: makeJsonFunctionBodyLines)
        jsonMakeJSONFunction.throws = true
        jsonMakeJSONFunction.returnType = "JSON"
        
        let jsonConvertibleExtension = Settings.Extension(name: type.name)
        jsonConvertibleExtension.inheritance = "JSONConvertible"
        jsonConvertibleExtension.filename = "\(type.name)JSONConvertible"
        jsonConvertibleExtension.accessControl = ""
        jsonConvertibleExtension.functions = [
            jsonInitFunction,
            jsonMakeJSONFunction
        ]
        jsonConvertibleExtension.imports = [
            "Vapor",
            "FluentProvider"
        ]
        return jsonConvertibleExtension
    }

    private func generateVaporModelResponseRepresentableExtension(forType type: Type) throws -> Settings.Extension {
        let responseRepresentableExtension = Settings.Extension(name: type.name)
        
        responseRepresentableExtension.inheritance = "ResponseRepresentable"
        responseRepresentableExtension.filename = "\(type.name)ResponseRepresentable"
        responseRepresentableExtension.accessControl = ""
        responseRepresentableExtension.imports = [
            "Vapor",
            "FluentProvider"
        ]
        return responseRepresentableExtension
    }

    private func generateVaporModelUpdateableExtension(forType type: Type) throws -> Settings.Extension {
        let updateableKeysAttribute = Settings.Class.Attribute(name: "updateableKeys", type: "[UpdateableKey<\(type.name)>]")
        updateableKeysAttribute.ref = .var
        updateableKeysAttribute.accessControl = "public static"
        
        var updateableKeysAttributeDynamicVarLines: [String] = [
            "return ["
        ]
        
        let typeNameLower = type.name.lowercased()
        
        for property in type.properties ?? [] {
            guard let propertyType = property.type else { continue }
            updateableKeysAttributeDynamicVarLines.append(contentsOf: [
                "    UpdateableKey(\(type.name).\(property.name)Key, \(propertyType.swiftType()).self) { \(typeNameLower), \(property.name) in",
                "        \(typeNameLower).\(property.name) = \(property.name)",
                "    },"
            ])
        }
        
        updateableKeysAttributeDynamicVarLines.append(contentsOf: [
            "]"
        ])
        
        updateableKeysAttribute.dynamicAttributeLines = updateableKeysAttributeDynamicVarLines
        
        let updateableExtension = Settings.Extension(name: type.name)
        updateableExtension.inheritance = "Updateable"
        updateableExtension.filename = "\(type.name)Updateable"
        updateableExtension.attributes = [updateableKeysAttribute]
        updateableExtension.accessControl = ""
        updateableExtension.imports = [
            "Vapor",
            "FluentProvider"
        ]
        
        return updateableExtension
    }
    
}
