//
//  Parser.Always+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the always-succeeding parser (Void output only):
//  emits nothing, exactly as parse consumes nothing.
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Always: @retroactive Serializer.`Protocol` where Output == Void {
    /// The buffer type this serializer appends to: the parse input type.
    public typealias Buffer = Input

    /// Explicit leaf body: both `Parser.Protocol` and `Serializer.Protocol`
    /// provide a `Body == Never` default getter; without this override Swift
    /// cannot pick between the two inherited candidates (the Coder.Witness
    /// precedent).
    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    /// Emits nothing; this parser neither consumes nor produces input.
    @inlinable
    public func serialize(_ output: Void, into buffer: inout Input) {
        // Always produces its value without consuming or emitting input.
    }
}
