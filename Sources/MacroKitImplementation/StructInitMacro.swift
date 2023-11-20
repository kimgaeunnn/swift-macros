import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `init` macro for struct.  For example
///
///     struct Car {
///         let id: String
///     }
///
///  will expand to
///
///     public struct Car {
///         let id: String
///
///         public init(id: String) {
///             self.id = id
///         }
///     }
///
public struct StructInitMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw StructInitError.onlyApplicableToStruct
        }
        
        let members = structDecl.memberBlock.members
            let variableDecl = members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
            let variablesName = variableDecl.compactMap { $0.bindings.first?.pattern }
            let variablesType = variableDecl.compactMap { $0.bindings.first?.typeAnnotation?.type }
            
            let initializer = try InitializerDeclSyntax(StructInitMacro.generateInitialCode(
                access: structDecl.modifiers.first(where: \.isNeededAccessLevelModifier),
                variablesName: variablesName,
                variablesType: variablesType
            )) {
                for name in variablesName {
                    ExprSyntax("self.\(name) = \(name)")
                }
            }
            
            return [DeclSyntax(initializer)]
    }
    
    static func generateInitialCode(
        access: DeclModifierListSyntax.Element?,
        variablesName: [PatternSyntax],
        variablesType: [TypeSyntax]
    ) -> SyntaxNodeString {
        var initialCode: String = "\(access?.description ?? "")init("
        for (name, type) in zip(variablesName, variablesType) {
            initialCode += "\(name): \(type), "
        }
        initialCode = String(initialCode.dropLast(2))
        initialCode += ")"
        
        return SyntaxNodeString(stringLiteral: initialCode)
    }
}


enum StructInitError: CustomStringConvertible, Error {
    case onlyApplicableToStruct
    
    var description: String {
        switch self {
        case .onlyApplicableToStruct: return "@StructInit can only be applied to a structure"
        }
    }
}

extension DeclModifierSyntax {
    var isNeededAccessLevelModifier: Bool {
        switch self.name.tokenKind {
        case .keyword(.public): return true
        default: return false
        }
    }
}
