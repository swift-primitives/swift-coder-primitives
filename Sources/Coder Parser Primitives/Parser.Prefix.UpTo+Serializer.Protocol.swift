//
//  Parser.Prefix.UpTo+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the up-to-delimiter prefix parser (previously
//  parse-only): the captured prefix is appended verbatim.
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Prefix.UpTo: @retroactive Serializer.`Protocol`
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

    /// Appends the captured prefix verbatim.
    @inlinable
    public func serialize(_ output: Input, into buffer: inout Input) {
        buffer.append(contentsOf: output)
    }
}
