//
//  GenerateAPI.swift
//  DuckStack
//
//  Created by Christoph Pageler on 24.07.17.
//

import Foundation
import RAML

public extension CommandGroup {
    
    public class Generate {
        
        public static func api(argMainRamlFile: String) {
            guard let absolutePath = FileFinder.absoluteFilePath(fromArgument: argMainRamlFile) else {
                return
            }
            
            do {
                let raml = try RAML(file: absolutePath.string)
                print("raml \(raml.title)")
            } catch {
                print("Failed parsing RAML File at path \(absolutePath)")
                exit(1)
            }
            
        }
        
    }
    
}
