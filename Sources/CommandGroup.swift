//
//  CommandGroup.swift
//  DuckStack
//
//  Created by Christoph Pageler on 24.07.17.
//

import RAML

public struct CommandGroup {
    public class Generate { }
    
    public static func ramlFromArg(argMainRamlFile: String, applyDefaults: Bool = true) -> RAML? {
        guard let absolutePath = FileFinder.absoluteFilePath(fromArgument: argMainRamlFile) else {
            print("Invalid Path \(argMainRamlFile)")
            return nil
        }
        
        guard let raml = try? RAML(file: absolutePath.string) else {
            print("Failed parsing RAML File at path \(absolutePath)")
            return nil
        }
        
        if applyDefaults {
            return raml.applyDefaults()
        } else {
            return raml
        }
    }
}
