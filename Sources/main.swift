import Foundation
import Commander
import PathKit

let main = command {
    Group {
        $0.group("generate", closure: {
            $0.command(
                "api",
                Option("raml", "api.raml"),
                Option("output", "./output"),
                Option("author", "")
            ) { (argMainRamlFile, argOutputDirectory, author) in
                let args = CommandGroup.Generate.APIArgs(mainRAMLFile: argMainRamlFile,
                                                         outputDirectory: argOutputDirectory,
                                                         author: author.characters.count > 0 ? author : nil,
                                                         clean: true)
                CommandGroup.Generate.api(args)
            }
        })
    }.run()
}

main.run()

