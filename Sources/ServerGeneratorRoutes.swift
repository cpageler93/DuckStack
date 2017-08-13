//
//  ServerGeneratorRoutes.swift
//  DuckStack
//
//  Created by Christoph Pageler on 30.07.17.
//

import Foundation
import RAML
import PathKit
import ChickGen

public extension ServerGenerator {
    
    internal func generateVaporRoutesAt(path: Path, settings: Settings) throws {
        
        let setupRoutesFunc = Settings.Class.Function(name: "setupRoutes",
                                                      bodyLines: try getVaporRoutesBodyLines())
        setupRoutesFunc.throws = true
        let routeExtension = Settings.Extension(name: "Droplet")
        routeExtension.filename = "Routes"
        routeExtension.functions = [setupRoutesFunc]
        
        settings.extensions = [routeExtension]
        
        let generateSettings = GenerateSettings(outputDirectory: path)
        let generator = ChickGenGenerator(settings: settings)
        try generator.generate(generateSettings)
    }
    
    private func getVaporRoutesBodyLines() throws -> [String] {
        var lines: [String] = []
        lines.append(contentsOf: try getVaporRoutesBodyLinesFor(someoneWhoHasResources: raml))
        return lines
    }
    
    private func getVaporRoutesBodyLinesFor(someoneWhoHasResources: HasResources,
                                            withParentGroupName parentGroupName: String? = nil,
                                            parentControllerName: String? = nil) throws -> [String] {
        let concreteParentGroupName = parentGroupName != nil ? "\(parentGroupName!)." : ""
        var lines: [String] = []
        for resource in someoneWhoHasResources.resources ?? [] {
            if let serverPathName = resource.vaporRoutePathName() {
                let groupName = "\(serverPathName)Group"
                let controllerName = "\(serverPathName)Controller"
                let controllerClassName = controllerName.capitalizingFirstLetter()
                lines.append(contentsOf: [
                    "// \(resource.displayName ?? "No Description")",
                    "let \(groupName) = \(concreteParentGroupName)grouped(\"\(serverPathName)\")",
                    "let \(controllerName) = \(controllerClassName)()"
                ])
                let childRoutes = try getVaporRoutesBodyLines(forResource: resource,
                                                              withParentGroupName: groupName,
                                                              parentControllerName: controllerName)
                lines.append(contentsOf: childRoutes)
            } else {
                guard let parentControllerName = parentControllerName else {
                    throw DuckStackError.unknownError
                }
                let childRoutes = try getVaporRoutesBodyLines(forResource: resource,
                                                              withParentGroupName: parentGroupName,
                                                              parentControllerName: parentControllerName)
                lines.append(contentsOf: childRoutes)
            }
        }
        return lines
    }
    
    private func getVaporRoutesBodyLines(forResource resource: Resource,
                                         withParentGroupName parentGroupName: String? = nil,
                                         parentControllerName: String? = nil) throws -> [String] {
        var lines: [String] = []
        
        if let resourceOfType = resource.resourceOfType() {
            lines.append(contentsOf: [
                "try resource(\"/\", \(resourceOfType)sController.self)"
            ])
        } else {
            let concreteParentGroupName = parentGroupName ?? "<undefined?>"
            let concreteParentControllerName = parentControllerName ?? "<undefined?>"
            
            let pathParams = resource.vaporRoutePathParams()
            let absolutePath = raml.absolutePathForResource(resource)
            
            for method in resource.methods ?? [] {
                let methodName = raml.vaporFunctionNameFor(method: method, inResource: resource)
                lines.append(contentsOf: [
                    "",
                    "// \(method.type.rawValue.uppercased()) \(absolutePath)",
                    "\(concreteParentGroupName).\(method.type.rawValue)(\(pathParams)) { req in ",
                    "    return try \(concreteParentControllerName).\(methodName)(req)",
                    "}",
                    ""
                    ])
            }
        }
        
        let subResourceLines = try getVaporRoutesBodyLinesFor(someoneWhoHasResources: resource,
                                                              withParentGroupName: parentGroupName,
                                                              parentControllerName: parentControllerName)
        lines.append(contentsOf: subResourceLines)
        
        return lines
    }
}
