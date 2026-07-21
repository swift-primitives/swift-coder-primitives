//
//  Parser.End+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the end-of-input marker: emits nothing.
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.End: @retroactive Serializer.`Protocol` {
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

    /// Emits nothing; end of input is a marker with no representation.
    @inlinable
    public func serialize(_ output: Void, into buffer: inout Input) {
        // End produces nothing — it is a marker.
    }
}
