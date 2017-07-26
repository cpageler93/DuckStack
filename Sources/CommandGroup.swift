//
//  CommandGroup.swift
//  DuckStack
//
//  Created by Christoph Pageler on 24.07.17.
//

import RAML

public struct CommandGroup {
    public class Generate { }
    
    public static func ramlFromArg(argMainRamlFile: String, applyDefaults: Bool = true) throws -> RAML? {
        guard let absolutePath = FileFinder.absoluteFilePath(fromArgument: argMainRamlFile) else {
            throw DuckStackError.invalidFile(atPath: argMainRamlFile)
        }
        
        do {
            let raml = try RAML(file: absolutePath.string)
            
            if applyDefaults {
                return raml.applyDefaults()
            } else {
                return raml
            }
        } catch {
            switch error {
            case let ramlError as RAMLError:
                throw DuckStackError.ramlError(error: ramlError)
            default:
                throw error
            }
        }
    }
}
