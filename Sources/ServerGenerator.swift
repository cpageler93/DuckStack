//
//  ServerGenerator.swift
//  DuckStack
//
//  Created by Christoph Pageler on 30.07.17.
//

import Foundation
import RAML
import PathKit
import ChickGen

public class ServerGenerator {
    
    let raml: RAML
    
    public init(raml: RAML) {
        self.raml = raml
    }
    
    public func generate(path: Path, settings: Settings) throws {
        let serverClassName = raml.swiftResourceServerClassName()
        let status = generateVaporServerProject(path: path, serverClassName: serverClassName)
        
        if status == 0 {
            let vaporProjectPath = path + Path(serverClassName)
            settings.clear()
            try generateVaporRoutesAt(path: vaporProjectPath + Path("Sources/App"), settings: settings)
            settings.clear()
            
            
        } else {
            print("something went wrong")
        }
    }
    
    private func generateVaporServerProject(path: Path, serverClassName: String) -> Int32 {
        let outputPipe = Pipe()
//        outputPipe.fileHandleForReading.readabilityHandler = { pipe in
//            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
//                print("LINE: \(line)")
//            }
//        }
        
        let vaporProcess = Process()
        vaporProcess.launchPath = "/usr/bin/env"
        vaporProcess.arguments = [
            "/usr/local/bin/vapor",
            "new",
            serverClassName,
            "--template=api"
        ]
        vaporProcess.currentDirectoryPath = path.string
        vaporProcess.standardOutput = outputPipe
        vaporProcess.launch()
        vaporProcess.waitUntilExit()
        
        return vaporProcess.terminationStatus
    }
    
    private func generateVaporRoutesAt(path: Path, settings: Settings) throws {
        
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
        lines.append(contentsOf: getVaporRoutesBodyLinesFor(someoneWhoHasResources: raml))
        return lines
    }
    
    private func getVaporRoutesBodyLinesFor(someoneWhoHasResources: HasResources,
                                            withParentGroupName parentGroupName: String? = nil) -> [String] {
        let concreteParentGroupName = parentGroupName != nil ? "\(parentGroupName!)." : ""
        var lines: [String] = []
        for resource in someoneWhoHasResources.resources ?? [] {
            if let serverPath = getVaporRoutePathFor(resource: resource) {
                let groupName = "\(serverPath)Group"
                lines.append(contentsOf: [
                    "// \(resource.displayName ?? "No Description")",
                    "let \(groupName) = \(concreteParentGroupName)grouped(\"\(serverPath)\")"
                    ])
                let childRoutes = getVaporRoutesBodyLines(forResource: resource, withParentGroupName: groupName)
                lines.append(contentsOf: childRoutes)
            } else {
                let childRoutes = getVaporRoutesBodyLines(forResource: resource, withParentGroupName: parentGroupName)
                lines.append(contentsOf: childRoutes)
            }
        }
        return lines
    }
    
    private func getVaporRoutesBodyLines(forResource resource: Resource,
                                         withParentGroupName parentGroupName: String? = nil) -> [String] {
        let concreteParentGroupName = parentGroupName ?? "<undefined?>"
        let pathParams = getVaporRoutePathParamsFor(resource: resource)
        let absolutePath = raml.absolutePathForResource(resource)
        
        var lines: [String] = []
        for method in resource.methods ?? [] {
            lines.append(contentsOf: [
                "",
                "// \(method.type.rawValue.uppercased()) \(absolutePath)",
                "\(concreteParentGroupName).\(method.type.rawValue)(\(pathParams)) { req in ",
                "   return \"FOO\"",
                "}",
                ""
            ])
        }
        
        let subResourceLines = getVaporRoutesBodyLinesFor(someoneWhoHasResources: resource, withParentGroupName: parentGroupName)
        lines.append(contentsOf: subResourceLines)
        
        return lines
    }
    
    private func getVaporRoutePathFor(resource: Resource) -> String? {
        var routePath = resource.path
        routePath = routePath.replacingParams { _ in "" }
        routePath = routePath.withRemovedPrefix("/")
        routePath = routePath.withRemovedSuffix("/")
        
        if routePath.characters.count > 0 {
            return routePath
        } else {
            return nil
        }
    }
    
    private func getVaporRoutePathParamsFor(resource: Resource) -> String {
        var params: [String] = []
        params.append("\"/\"")
        for uriParameter in resource.uriParameters ?? [] {
            params.append("\":\(uriParameter.identifier)\"")
        }
//        "/", ":id"
        return params.joined(separator: ", ")
    }
    
}
