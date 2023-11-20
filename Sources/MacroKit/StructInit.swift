
// MARK: - Initialize

@attached(member, names: named(init))
public macro StructInit() = #externalMacro(module: "MacroKitImplementation", type: "StructInitMacro")
