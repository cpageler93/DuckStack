//
//  ServerGeneratorModels.swift
//  DuckStack
//
//  Created by Christoph Pageler on 30.07.17.
//

import Foundation
import RAML
import PathKit
import ChickGen


public extension ServerGenerator {
    
    internal func generateVaporModelsAt(path: Path, settings: Settings) throws {
        for type in raml.types ?? [] {
            let newType = try generateVaporModelFor(type: type)
            settings.classes.append(newType)
        }
        
        let generateSettings = GenerateSettings(outputDirectory: path)
        let generator = ChickGenGenerator(settings: settings)
        try generator.generate(generateSettings)
    }
    
    private func generateVaporModelFor(type: Type) throws -> Settings.Class {
        let attributes = try vaporModelAttributesFor(type: type)
        let functions = try vaporModelFunctionsFor(type: type)
        
        
        let modelClass = Settings.Class(name: "Duck_\(type.name)", attributes: attributes, functions: functions)
        modelClass.superclass = "Model"
        modelClass.accessControl = "final"
        modelClass.imports = [
            "Vapor",
            "FluentProvider",
            "HTTP"
        ]
        
        return modelClass
    }
    
    private func vaporModelAttributesFor(type: Type) throws -> [Settings.Class.Attribute] {
        var attributes: [Settings.Class.Attribute] = []
        
        // static attributes
        let storageAttribute = Settings.Class.Attribute(name: "storage", type: "Storage")
        storageAttribute.defaultValue = "Storage()"
        storageAttribute.accessControl = ""
        attributes.append(contentsOf: [
            storageAttribute
        ])
        
        // dynamic attributes
        for property in type.properties ?? [] {
            guard let type = property.type else {
                continue
            }
            let propertyAttribute = Settings.Class.Attribute(ref: Settings.ClassRef.var,
                                                             name: property.name,
                                                             type: type.swiftType(),
                                                             optional: false)
            propertyAttribute.accessControl = ""
            propertyAttribute.optional = property.swiftOptional()
            
            attributes.append(propertyAttribute)
        }
        
        for property in type.properties ?? [] {
            let propertyAttribute = Settings.Class.Attribute(ref: Settings.ClassRef.let,
                                                             name: "\(property.name)Key",
                                                             type: "String",
                                                             optional: false)
            propertyAttribute.defaultValue = "\"\(property.name)\""
            propertyAttribute.accessControl = "static"
            
            attributes.append(propertyAttribute)
        }
        
        return attributes
    }
    
    private func vaporModelFunctionsFor(type: Type) throws -> [Settings.Class.Function] {
        return [
            try vaporModelInitFunctionFor(type: type),
            try vaporModelInitRowFunctionFor(type: type),
            try vaporModelMakeRowFunctionFor(type: type)
        ]
    }
    
    private func vaporModelInitFunctionFor(type: Type) throws -> Settings.Class.Function {
        var params: [Settings.Class.FunctionParameter] = []
        var bodyLines: [String] = []
        
        for property in type.properties ?? [] {
            guard let propertyType = property.type else { continue }
            if property.swiftOptional() { continue }
            let param = Settings.Class.FunctionParameter(name: property.name,
                                                         type: propertyType.swiftType())
            params.append(param)
            
            
            bodyLines.append("self.\(property.name) = \(property.name)")
        }
        
        
        let initFunction = Settings.Class.Function(name: "init",
                                                   parameters: params,
                                                   bodyLines: bodyLines)
        return initFunction
    }
    
    private func vaporModelInitRowFunctionFor(type: Type) throws -> Settings.Class.Function {
        var bodyLines: [String] = []
        
        for property in type.properties ?? [] {
            bodyLines.append("\(property.name) = try row.get(\(type.name).\(property.name)Key)")
        }
        
        let params: [Settings.Class.FunctionParameter] = [
            Settings.Class.FunctionParameter(name: "row", type: "Row")
        ]
        let initFunction = Settings.Class.Function(name: "init",
                                                   parameters: params,
                                                   bodyLines: bodyLines)
        initFunction.throws = true
        return initFunction
    }
    
    private func vaporModelMakeRowFunctionFor(type: Type) throws -> Settings.Class.Function {
        var bodyLines: [String] = [
            "var row = Row()"
        ]
        
        for property in type.properties ?? [] {
            bodyLines.append("try row.set(\(type.name).\(property.name)Key, \(property.name))")
        }
        bodyLines.append(contentsOf: [
            "return row"
        ])
        
        let makeRowFunction = Settings.Class.Function(name: "makeRow",
                                                      parameters: [],
                                                      bodyLines: bodyLines)
        makeRowFunction.throws = true
        makeRowFunction.returnType = "Row"
        return makeRowFunction
    }
        
}
