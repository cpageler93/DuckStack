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
            
            let ref = property.isPrimaryKey() ? Settings.ClassRef.let : Settings.ClassRef.var
            
            let newAttribute = Settings.Class.Attribute(ref: ref,
                                                        name: property.name,
                                                        type: type.swiftType(),
                                                        optional: property.swiftIsOptional())
            attributes.append(newAttribute)
        }
        
        let functions = [
            initWithJsonMethodFor(type: type)
        ]
        
        let newClass = Settings.Class(name: type.name,
                                      attributes: attributes,
                                      functions: functions)
        newClass.imports = [
            "Foundation",
            "Quack",
            "SwiftyJSON"
        ]

        
        return newClass
    }
    
    private func initWithJsonMethodFor(type: Type) -> Settings.Class.Function {
        var bodyLines: [String] = []
        
        for (index, property) in (type.properties ?? []).enumerated() {
            if index != 0 {
                bodyLines.append(contentsOf: [
                    ""
                ])
            }
            bodyLines.append(contentsOf: [
                "// init \(property.name)"
            ])
            if property.swiftIsOptional() {
                bodyLines.append(contentsOf: [
                    "self.\(property.name) = json[\"\(property.name)\"].string"
                    ])
            } else {
                bodyLines.append(contentsOf: [
                    "guard let \(property.name) = json[\"\(property.name)\"].string else { return nil }",
                    "self.\(property.name) = property.name"
                    ])
            }
        }
        
        let initMethod = Settings.Class.Function(name: "init?",
                                                parameters: [Settings.Class.FunctionParameter(name: "json", type: "JSON")],
                                                bodyLines: bodyLines)
        initMethod.accessControl = "required public"
        return initMethod
    }
    
}
