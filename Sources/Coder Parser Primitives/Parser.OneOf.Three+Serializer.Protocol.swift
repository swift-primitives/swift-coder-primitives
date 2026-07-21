//
//  Parser.OneOf.Three+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the three-way alternation with value-checkpoint
//  backtracking (buffer restored by value copy between attempts).
//

public import Parser_Primitives
public import Product_Primitives
public import Serializer_Primitives_Core

extension Parser.OneOf.Three: @retroactive Serializer.`Protocol`
where
    P0: Serializer.`Protocol`,
    P1: Serializer.`Protocol`,
    P2: Serializer.`Protocol`,
    P0.Buffer == P1.Buffer,
    P1.Buffer == P2.Buffer
{
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

    /// Tries each serializer in order, restoring the buffer between attempts,
    /// until one succeeds.
    @inlinable
    public func serialize(
        _ output: Output,
        into buffer: inout Buffer
    ) throws(Product<P0.Failure, P1.Failure, P2.Failure>) {
        let checkpoint = buffer
        do throws(P0.Failure) {
            try p0.serialize(output, into: &buffer)
            return
        } catch let error0 {
            buffer = checkpoint
            do throws(P1.Failure) {
                try p1.serialize(output, into: &buffer)
                return
            } catch let error1 {
                buffer = checkpoint
                do throws(P2.Failure) {
                    try p2.serialize(output, into: &buffer)
                } catch let error2 {
                    buffer = checkpoint
                    throw Product(error0, error1, error2)
                }
            }
        }
    }
}
