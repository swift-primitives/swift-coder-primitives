//
//  Parser.OneOf.Two+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the two-way alternation with value-checkpoint
//  backtracking: the pre-branch buffer is captured by value copy and
//  restored on branch failure — no `Input.Protocol` cursor machinery.
//

public import Parser_Primitives
public import Product_Primitives
public import Serializer_Primitives_Core

extension Parser.OneOf.Two: @retroactive Serializer.`Protocol`
where P0: Serializer.`Protocol`, P1: Serializer.`Protocol`, P0.Buffer == P1.Buffer {
    /// The buffer type this serializer appends to.
    public typealias Buffer = P0.Buffer

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

    /// Tries the first serializer; on failure, restores the buffer to its
    /// pre-branch state (value-copy checkpoint) and tries the second.
    @inlinable
    public func serialize(
        _ output: Output,
        into buffer: inout Buffer
    ) throws(Product<P0.Failure, P1.Failure>) {
        let checkpoint = buffer
        do throws(P0.Failure) {
            try p0.serialize(output, into: &buffer)
            return
        } catch let error0 {
            buffer = checkpoint
            do throws(P1.Failure) {
                try p1.serialize(output, into: &buffer)
            } catch let error1 {
                buffer = checkpoint
                throw Product(error0, error1)
            }
        }
    }
}
