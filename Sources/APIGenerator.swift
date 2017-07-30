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
    
    private func clientPath() -> Path {
        return Path(outputDirectory) + Path("client")
    }
    
    private func serverPath() -> Path {
        return Path(outputDirectory) + Path("server")
    }
    
    public func clean() throws {
        let cp = clientPath()
        if cp.exists && cp.isDeletable {
            try cp.delete()
        }
        
        let sp = serverPath()
        if sp.exists && sp.isDeletable {
            try sp.delete()
        }
    }
    
    public func generate() throws {
        let path = Path(outputDirectory)
        if !path.exists {
            throw DuckStackError.invalidFile(atPath: path.string)
        }
        
        let cp = clientPath()
        if !cp.exists {
            try cp.mkdir()
        }
        
        let sp = serverPath()
        if !sp.exists {
            try sp.mkdir()
        }
        
        try generateClient(path: cp)
        try generateServer(path: sp)
    }
    
    private func getNewSettings() -> Settings {
        let settings = Settings()
        
        settings.general.projectName = raml.title
        settings.general.author      = author
        
        return settings
    }
    
    private func generateClient(path: Path) throws {
        // prepare settings
        var settings = getNewSettings()
        TypeGenerator(types: raml.types).generateFor(settings: &settings)
        try ResourceGenerator(raml: raml).generateFor(settings: &settings)
        
        // prepare output
        let generateSettings = GenerateSettings(outputDirectory: path)
        
        // generate files
        let generator = ChickGenGenerator(settings: settings)
        try generator.generate(generateSettings)
    }
    
    private func generateServer(path: Path) throws {
        let generator = ServerGenerator(raml: raml)
        try generator.generate(path: path, settings: getNewSettings())
    }
    
}
