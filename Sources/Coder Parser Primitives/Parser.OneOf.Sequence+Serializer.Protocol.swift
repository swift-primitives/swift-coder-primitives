//
//  Parser.OneOf.Sequence+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Builder-propagation: forward emission through the OneOf.Sequence
//  builder-entry wrapper to its composed body.
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.OneOf.Sequence: @retroactive Serializer.`Protocol`
where Body: Serializer.`Protocol` {
    /// The buffer type this serializer appends to.
    public typealias Buffer = Body.Buffer

    /// Explicit `Serializer.Protocol.body` witness.
    ///
    /// Workaround for a Swift toolchain defect (6.4.x-nightly and main-nightly):
    /// letting the cross-module stored `let body` witness this requirement makes
    /// the SIL verifier reject its read accessor as a bodiless
    /// `shared [serialized]` function while lowering this module
    /// ("public/package/shared function must have a body"). Routing the witness
    /// through the `Parser.Protocol` witness table avoids the direct
    /// cross-module accessor reference.
    ///
    /// Tracked: swift-primitives/swift-coder-primitives#3; reproducer:
    /// swift-institute/Issues#88. Remove when the toolchain floor carries the fix.
    public var body: Body { parserProtocolBody }

    /// Serializes by delegating to the composed body.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try body.serialize(output, into: &buffer)
    }
}
