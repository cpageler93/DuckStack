import Foundation
import Commander
import PathKit

let main = command {
    Group {
        $0.group("generate", closure: {
            $0.command("api") { (argMainRamlFile: String) in
                CommandGroup.Generate.api(argMainRamlFile: argMainRamlFile)
            }
        })
    }.run()
}

main.run()

