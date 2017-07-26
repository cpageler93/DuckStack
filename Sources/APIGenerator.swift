//
//  APIGenerator.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation
import RAML
import ChickGen
import PathKit

public class APIGenerator {
    
    public let raml: RAML
    public let outputDirectory: String
    public let author: String?
    
    public init(raml: RAML, outputDirectory: String, author: String?) {
        self.raml = raml
        self.outputDirectory = FileFinder.cleanHomeDirectory(fromString: outputDirectory)
        self.author = author
    }
    
    public func generate() throws {
        // prepare settings
        var settings = Settings()
        settings.general.projectName = raml.title
        settings.general.author      = author
        TypeGenerator(types: raml.types).generateFor(settings: &settings)
        try ResourceGenerator(raml: raml).generateFor(settings: &settings)
        
        // prepare output
        let generateSettings = GenerateSettings(outputDirectory: Path(outputDirectory))
        
        // generate files
        let generator = ChickGenGenerator(settings: settings)
        try generator.generate(generateSettings)
    }
    
}
