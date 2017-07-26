//
//  FileFinder.swift
//  DuckStack
//
//  Created by Christoph Pageler on 24.07.17.
//

import Foundation
import PathKit

public class FileFinder {
    
    public static func cleanHomeDirectory(fromString string: String) -> String {
        // replace ~ with absolute home directory
        return string.replacingOccurrences(of: "~", with: NSHomeDirectory())
    }
    
    public static func absoluteFilePath(fromArgument string: String) -> Path? {
        // replace ~ with absolute home directory
        var filepath = Path(cleanHomeDirectory(fromString: string))
        
        // make path absolute
        if filepath.isRelative {
            filepath = Path(FileManager.default.currentDirectoryPath) + filepath
        }
        
        if !filepath.exists{
            print("no file at \(filepath)")
            return nil
        }
        
        return filepath
    }
    
}

