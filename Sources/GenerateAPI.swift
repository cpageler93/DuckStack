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
        let clean: Bool
    }
    
    public static func api(_ args: APIArgs) {
        do {
            // parse raml
            guard let raml = try CommandGroup.ramlFromArg(argMainRamlFile: args.mainRAMLFile) else { return }
            
            // generate api from raml
            let apiGenerator = APIGenerator(raml: raml, outputDirectory: args.outputDirectory, author: args.author)
            
            if args.clean {
                try apiGenerator.clean()
            }
            
            try apiGenerator.generate()
        } catch {
            switch error {
            case let duckStackError as DuckStackError:
                print("Error: \(duckStackError.localizedDescription)")
            default:
                print("Error: \(error.localizedDescription)")
            }
            return
        }
    }
    
}
