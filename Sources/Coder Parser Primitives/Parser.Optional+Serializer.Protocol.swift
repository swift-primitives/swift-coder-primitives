//
//  Parser.Optional+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the compile-time-optional combinator.
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Optional: @retroactive Serializer.`Protocol`
where Wrapped: Serializer.`Protocol` {
    /// The buffer type this serializer appends to.
    public typealias Buffer = Wrapped.Buffer

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

    /// Serializes the wrapped output when both the serializer and the value
    /// are present.
    @inlinable
    public func serialize(
        _ output: Wrapped.Output?,
        into buffer: inout Buffer
    ) throws(Wrapped.Failure) {
        guard let wrapped, let output else { return }
        try wrapped.serialize(output, into: &buffer)
    }
}
