//
//  DataTypeExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import RAML

public extension DataType {
    
    public func swiftType() -> String {
        switch self {
        case .any:                  return "Any"
        case .object:               return "Any"
        case .array(let ofType):    return "[\(ofType.swiftType())]"
        case .custom(let type):     return type
        case .scalar(let scalarType):
            switch scalarType {
            case .number:           return "Number"
            case .boolean:          return "Bool"
            case .string:           return "String"
            case .dateOnly:         return "Date"
            case .timeOnly:         return "Date"
            case .dateTimeOnly:     return "Date"
            case .dateTime:         return "Date"
            case .file:             return "Data"
            case .integer:          return "Int"
            case .nil:              return "Nil"
            }
        case .union:                return "[Any]"
        }
    }
    
}
