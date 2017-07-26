//
//  TypeGenerator.swift
//  DuckStack
//
//  Created by Christoph Pageler on 25.07.17.
//

import Foundation
import RAML
import ChickGen

public class TypeGenerator {
    
    public let types: [Type]?
    
    public init(types: [Type]?) {
        self.types = types
    }
    
    public func generateFor(settings: inout Settings) {
        var newClasses: [Settings.Class] = []
        for type in types ?? [] {
            let newClass = classFrom(type: type)
            newClasses.append(newClass)
        }
        settings.classes.append(contentsOf: newClasses)
    }
    
    private func classFrom(type: Type) -> Settings.Class {
        var attributes: [Settings.Class.Attribute] = []
        for property in type.properties ?? [] {
            guard let type = property.type else { continue }
            let optional = !(property.required ?? true)
            
            let newAttribute = Settings.Class.Attribute(ref: .let,
                                                        name: property.name,
                                                        type: type.swiftType(),
                                                        optional: optional)
            attributes.append(newAttribute)
        }
        
        let newClass = Settings.Class(name: type.name,
                                      attributes: attributes,
                                      functions: [])
        newClass.imports = [
            "Foundation"
        ]
        
        return newClass
    }
    
}
