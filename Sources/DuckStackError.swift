//
//  DuckStackError.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation
import RAML

public enum DuckStackError: Error {
    
    case invalidFile(atPath: String)
    case ramlError(error: RAMLError)
    case noValidResponseFor(method: ResourceMethod)
    case noValidBodyTypeInResponseFor(method: ResourceMethod)
    case unknownError
    
    public var localizedDescription: String {
        switch self {
        case .invalidFile(let atPath): return "Invalid file at path `\(atPath)`"
        case .ramlError(let error): return "RAML Error \(error.localizedDescription)"
        case .noValidResponseFor(let method): return "No Valid Response for Method `\(method.displayName ?? "<displayName>")`"
        case .noValidBodyTypeInResponseFor(let method): return "No valid Body Type in Response for Method `\(method.displayName ?? "<displayName>")`"
        case .unknownError: return "Unknown Error"
        }
    }
    
}
