//
//  Array+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the Array literal parser: appends the literal
//  elements at the buffer's end (the retired print inserted at the front).
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Swift.Array: @retroactive Serializer.`Protocol` where Element: Equatable {
    /// The buffer type this serializer appends to: the parse input type.
    public typealias Buffer = ArraySlice<Element>

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

    /// Appends this literal's elements to the buffer.
    @inlinable
    public func serialize(_ output: Void, into buffer: inout ArraySlice<Element>) {
        buffer.append(contentsOf: self)
    }
}
