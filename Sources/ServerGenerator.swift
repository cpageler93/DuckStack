//
//  ServerGenerator.swift
//  DuckStack
//
//  Created by Christoph Pageler on 30.07.17.
//

import Foundation
import RAML
import PathKit
import ChickGen

public class ServerGenerator {
    
    let raml: RAML
    
    public init(raml: RAML) {
        self.raml = raml
    }
    
    public func generate(path: Path, settings: Settings) throws {
        let serverClassName = raml.swiftResourceServerClassName()
        let status = generateVaporServerProject(path: path, serverClassName: serverClassName)
        
        if status == 0 {
            let vaporProjectPath = path + Path(serverClassName)
            settings.clear()
            try generateVaporRoutesAt(path: vaporProjectPath + Path("Sources/App"), settings: settings)
            settings.clear()
            try generateVaporModelsAt(path: vaporProjectPath + Path("Sources/App/Models"), settings: settings)
            settings.clear()
            try generateVaporConfigsAt(path: vaporProjectPath + Path("Sources/App"), settings: settings)
            settings.clear()
            try generateVaporControllersAt(path: vaporProjectPath + Path("Sources/App/Controllers"), settings: settings)
            
            
        } else {
            print("something went wrong")
        }
    }
    
    private func generateVaporServerProject(path: Path, serverClassName: String) -> Int32 {
        let outputPipe = Pipe()
//        outputPipe.fileHandleForReading.readabilityHandler = { pipe in
//            if let line = String(data: pipe.availableData, encoding: String.Encoding.utf8) {
//                print("LINE: \(line)")
//            }
//        }
        
        let vaporProcess = Process()
        vaporProcess.launchPath = "/usr/bin/env"
        vaporProcess.arguments = [
            "/usr/local/bin/vapor",
            "new",
            serverClassName,
            "--template=api"
        ]
        vaporProcess.currentDirectoryPath = path.string
        vaporProcess.standardOutput = outputPipe
        vaporProcess.launch()
        vaporProcess.waitUntilExit()
        
        return vaporProcess.terminationStatus
    }
    
}
