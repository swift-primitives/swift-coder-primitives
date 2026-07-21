//
//  Pair+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Forward-order append emission for Pair<First, Second> as a sequential
//  parser combinator (round-trip symmetry for the Pair-as-Parser
//  conformance in swift-parser-primitives).
//

public import Either_Primitives
public import Pair_Primitives
public import Parser_Primitives
public import Serializer_Primitives_Core

extension Pair: @retroactive Serializer.`Protocol`
where
    First: Parser.`Protocol` & Serializer.`Protocol`,
    Second: Parser.`Protocol` & Serializer.`Protocol`,
    First.Input == Second.Input,
    First.Buffer == Second.Buffer
{
    /// The buffer type this serializer appends to.
    public typealias Buffer = First.Buffer

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

    /// Serializes both outputs in FORWARD (parse) order.
    @inlinable
    public borrowing func serialize(
        _ output: (First.Output, Second.Output),
        into buffer: inout First.Buffer
    ) throws(Either<First.Failure, Second.Failure>) {
        do throws(First.Failure) {
            try first.serialize(output.0, into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(Second.Failure) {
            try second.serialize(output.1, into: &buffer)
        } catch {
            throw .right(error)
        }
    }
}
