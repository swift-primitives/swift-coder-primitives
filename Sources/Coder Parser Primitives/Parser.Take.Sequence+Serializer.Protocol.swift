//
//  Parser.Take.Sequence+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Builder-propagation: forward emission through the Take.Sequence
//  builder-entry wrapper to its composed body.
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Take.Sequence: @retroactive Serializer.`Protocol`
where Body: Serializer.`Protocol` {
    /// The buffer type this serializer appends to.
    public typealias Buffer = Body.Buffer

    /// Serializes by delegating to the composed body.
    @inlinable
    public func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try body.serialize(output, into: &buffer)
    }
}
