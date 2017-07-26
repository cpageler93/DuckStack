//
//  StringExtensions.swift
//  DuckStack
//
//  Created by Christoph Pageler on 26.07.17.
//

import Foundation

public extension String {
    
    public func camelCasedString() -> String {
        var source = self
        while source.contains(" ") {
            // remove space
            guard let rangeOfSpace = source.range(of: " ") else { break }
            source = source.replacingCharacters(in: rangeOfSpace, with: "")
            
            // uppercase next char after space when:
            // - space was not at beginning of the string
            // - there is a next char
            if rangeOfSpace.lowerBound != source.startIndex && source.endIndex >= rangeOfSpace.upperBound {
                // uppercase next char
                let nextChar = source.substring(with: rangeOfSpace)
                source = source.replacingCharacters(in: rangeOfSpace, with: nextChar.uppercased())
            }
        }
        return source
    }
    
    public func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    public mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    public func swiftClassName() -> String {
        var className = self
        className = className.camelCasedString()
        className = className.capitalizingFirstLetter()
        return className
    }
    
}
