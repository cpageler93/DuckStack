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
    
    public func replacingParams(with block: (String) -> (String)) -> String {
        var source = self
        do {
//            let parameterRegex = try NSRegularExpression(pattern: "\\\(from)(.*)\\\(to)")
            let parameterRegex = try NSRegularExpression(pattern: "\\{([^*\\{\\}]*)\\}")
            var parameterMatches: [NSTextCheckingResult] = []
            repeat {
                parameterMatches = parameterRegex.matches(in: source, options: [], range: NSMakeRange(0, source.characters.count))
                guard let firstMatch = parameterMatches.first else { break }
                let bigRange = firstMatch.rangeAt(0)
                let smallRange = firstMatch.rangeAt(1)
                
                let nsSource = source as NSString
                let parameterName = nsSource.substring(with: smallRange)
                let newValue = block(parameterName)
                source = nsSource.replacingCharacters(in: bigRange, with: newValue)
                
            } while(parameterMatches.count > 0)
            
        } catch {
            
        }
        return source
    }
    
    public func withRemovedPrefix(_ prefix: String) -> String {
        let source = self
        if source.hasPrefix(prefix) {
            return String(source.dropFirst(prefix.characters.count))
        } else {
            return source
        }
    }
    
    public func withRemovedSuffix(_ suffix: String) -> String {
        let source = self
        if source.hasSuffix(suffix) {
            return String(source.dropLast(suffix.characters.count))
        } else {
            return source
        }
    }
    
}
