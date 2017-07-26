//
//  GenerateAPI.swift
//  DuckStack
//
//  Created by Christoph Pageler on 24.07.17.
//

import Foundation

public extension CommandGroup.Generate {
    
    public struct APIArgs {
        let mainRAMLFile: String
        let outputDirectory: String
        let author: String?
    }
    
    public static func api(_ args: APIArgs) {
        guard let raml = CommandGroup.ramlFromArg(argMainRamlFile: args.mainRAMLFile) else { return }
        let apiGenerator = APIGenerator(raml: raml, outputDirectory: args.outputDirectory, author: args.author)
        do {
            try apiGenerator.generate()
        } catch {
            print("Failed Generating")
            return
        }
    }
    
}
