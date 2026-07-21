//
//  Parser.Skip.First+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Forward-order append emission: skipped (Void) child first, kept child
//  second — matching parse order.
//

public import Either_Primitives
public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Skip.First: @retroactive Serializer.`Protocol`
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

    /// Serializes the skipped first child's empty output, then the kept output.
    @inlinable
    public func serialize(
        _ output: P1.Output,
        into buffer: inout Buffer
    ) throws(Either<P0.Failure, P1.Failure>) {
        do throws(P0.Failure) {
            try p0.serialize((), into: &buffer)
        } catch {
            throw .left(error)
        }
        do throws(P1.Failure) {
            try p1.serialize(output, into: &buffer)
        } catch {
            throw .right(error)
        }
    }
}
