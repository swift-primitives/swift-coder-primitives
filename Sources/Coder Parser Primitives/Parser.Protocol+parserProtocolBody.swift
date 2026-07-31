//
//  Parser.Protocol+parserProtocolBody.swift
//  swift-coder-primitives
//
//  Toolchain-defect workaround support: a generic accessor for
//  `Parser.Protocol.body` used as an explicit `Serializer.Protocol.body`
//  witness by the builder-entry wrappers in this target.
//

public import Parser_Primitives

extension Parser.`Protocol` where Self: ~Copyable, Body: Copyable {
    /// The composed parser body, fetched through the `Parser.Protocol`
    /// witness table.
    ///
    /// Workaround for a Swift toolchain defect (6.4.x-nightly and
    /// main-nightly): an implicit `Serializer.Protocol.body` witness selecting
    /// a cross-module stored `let` makes the SIL verifier reject the stored
    /// property's read accessor as a bodiless `shared [serialized]` function
    /// while lowering this module. Fetching the body through this protocol
    /// requirement keeps the reference behind the witness table.
    ///
    /// Tracked: swift-primitives/swift-coder-primitives#3; reproducer:
    /// swift-institute/Issues#88. Remove when the toolchain floor carries the fix.
    internal var parserProtocolBody: Body { body }
}
