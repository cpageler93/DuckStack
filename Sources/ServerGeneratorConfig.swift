//
//  ServerGeneratorConfig.swift
//  DuckStack
//
//  Created by Christoph Pageler on 31.07.17.
//

import Foundation
import RAML
import PathKit
import ChickGen


public extension ServerGenerator {
    
    internal func generateVaporConfigsAt(path: Path, settings: Settings) throws {
        try generateVaporConfigSetupAt(path: path, settings: settings)
    }
    
    private func generateVaporConfigSetupAt(path: Path, settings: Settings) throws {
        let configSetupExtension = Settings.Extension(name: "Config")
        configSetupExtension.accessControl = ""
        configSetupExtension.filename = "Config+Setup"
        configSetupExtension.imports = [
            "FluentProvider"
        ]
        
        let setupMethod = Settings.Class.Function(name: "setup", parameters: nil, bodyLines: [
            "Node.fuzzy = [Row.self, JSON.self, Node.self]",
            "try setupProviders()",
            "try setupPreparations()"
        ])
        setupMethod.throws = true
        setupMethod.accessControl = "public"
        
        let setupProviders = Settings.Class.Function(name: "setupProviders", parameters: nil, bodyLines: [
            "try addProvider(FluentProvider.Provider.self)"
        ])
        setupProviders.throws = true
        setupProviders.accessControl = "private"
        
        var setupPreparationsLines: [String] = []
        
        for type in raml.types ?? [] {
            setupPreparationsLines.append("preparations.append(\(type.name).self)")
        }
        
        let setupPreparations = Settings.Class.Function(name: "setupPreparations", parameters: nil, bodyLines: setupPreparationsLines)
        setupPreparations.accessControl = "private"
        setupPreparations.throws = true
        
        
        configSetupExtension.functions = [
            setupMethod,
            setupProviders,
            setupPreparations
        ]
        
        settings.extensions = [
            configSetupExtension
        ]
        
        let generateSettings = GenerateSettings(outputDirectory: path)
        let generator = ChickGenGenerator(settings: settings)
        try generator.generate(generateSettings)
    }
    
}

