import SwiftCompilerPlugin
import SwiftSyntaxMacros


@main
public struct SwiftMacrosPlugin: CompilerPlugin {
    public let providingMacros: [Macro.Type] = [
        StructInitMacro.self,
    ]
    
    public init() { }
}
