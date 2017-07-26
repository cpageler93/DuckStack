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
    
}
