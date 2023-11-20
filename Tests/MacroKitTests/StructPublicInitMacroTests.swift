import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest


#if canImport(MacroKitImplementation)
import MacroKitImplementation

let testMacros: [String: Macro.Type] = [
    "StructInit": StructInitMacro.self,
]

final class StructPublicInitMacroTests: XCTestCase {
    func testMecro() {
        assertMacroExpansion(
        """
        @StructInit
        public struct Car {
            var id: String
            var mileage: Int
            var owner: String?
            var status: StatusType
        }
        """,
        expandedSource:
        """
        
        public struct Car {
            var id: String
            var mileage: Int
            var owner: String?
            var status: StatusType
        
            public init(id: String, mileage: Int, owner: String?, status: StatusType) {
                self.id = id
                self.mileage = mileage
                self.owner = owner
                self.status = status
            }
        }
        """,
        macros: testMacros
        )
    }
}

#endif
