//
//  String+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the String literal parser: appends the literal at the
//  buffer's end (the retired print inserted at the front).
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Swift.String: @retroactive Serializer.`Protocol` {
    /// The buffer type this serializer appends to: the parse input type.
    public typealias Buffer = Substring

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

    /// Appends this literal to the buffer.
    @inlinable
    public func serialize(_ output: Void, into buffer: inout Substring) {
        buffer.append(contentsOf: self)
    }
}
