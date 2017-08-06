//
//  ServerGeneratorControllers.swift
//  DuckStack
//
//  Created by Christoph Pageler on 06.08.17.
//

import Foundation
import RAML
import PathKit
import ChickGen


public extension ServerGenerator {
    
    internal func generateVaporControllersAt(path: Path, settings: Settings) throws {
        let classes = try controllerClassesWith(someoneWhoHasResources: raml)
        settings.classes.append(contentsOf: classes)
        
        let generateSettings = GenerateSettings(outputDirectory: path)
        let generator = ChickGenGenerator(settings: settings)
        try generator.generate(generateSettings)
    }
    
    private func controllerClassesWith(someoneWhoHasResources: HasResources,
                                       parentController: Settings.Class? = nil) throws -> [Settings.Class] {
        var controllerClasses: [Settings.Class] = []
        
        for resource in someoneWhoHasResources.resources ?? [] {
            if let serverPathName = resource.vaporRoutePathName() {
                let controllerName = "\(serverPathName)Controller"
                let controllerClassName = controllerName.capitalizingFirstLetter()
                
                let newClass = generateVaporControllerFor(resource: resource, controllerClassName: controllerClassName)
                
                controllerClasses.append(newClass)
                
                let childClasses = try controllerClassesWith(someoneWhoHasResources: resource,
                                                             parentController: newClass)
                controllerClasses.append(contentsOf: childClasses)
            } else {
                guard let parentController = parentController else {
                    throw DuckStackError.unknownError
                }
                
                let childFunctions = generateVaporControllerFunctionsFor(resource: resource)
                parentController.functions?.append(contentsOf: childFunctions)
                
                let childClasses = try controllerClassesWith(someoneWhoHasResources: resource,
                                                             parentController: parentController)
                controllerClasses.append(contentsOf: childClasses)
            }
            
        }
        
        return controllerClasses
    }
    
    private func generateVaporControllerFor(resource: Resource, controllerClassName: String) -> Settings.Class {
        let controllerClass = Settings.Class(name: controllerClassName,
                                             attributes: [],
                                             functions: generateVaporControllerFunctionsFor(resource: resource))
//        controllerClass.superclass = "ResourceRepresentable"
        controllerClass.accessControl = "final"
        controllerClass.imports = [
            "Vapor",
            "HTTP"
        ]
        
        return controllerClass
    }
    
    private func generateVaporControllerFunctionsFor(resource: Resource) -> [Settings.Class.Function] {
        var functions: [Settings.Class.Function] = []
        
        for method in resource.methods ?? [] {
            let methodName = raml.vaporFunctionNameFor(method: method, inResource: resource)
            var lines: [String] = []
            lines.append(contentsOf: [
                "return \"\(methodName)\""
            ])
            let requestParameter = Settings.Class.FunctionParameter(name: "req", type: "Request")
            requestParameter.label = "_"
            
            let function = Settings.Class.Function(name: methodName, parameters: [requestParameter], bodyLines: lines)
            function.throws = true
            function.returnType = "ResponseRepresentable"
            functions.append(function)
        }
        
        return functions
    }
    
}
