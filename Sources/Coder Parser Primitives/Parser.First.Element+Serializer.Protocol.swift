//
//  Parser.First.Element+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the single-element leaf: appends the element at the
//  buffer's end (the retired print inserted at the front).
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.First.Element: @retroactive Serializer.`Protocol`
where Input: RangeReplaceableCollection {
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

    /// Appends the element to the buffer.
    @inlinable
    public func serialize(_ output: Input.Element, into buffer: inout Input) {
        buffer.append(output)
    }
}
