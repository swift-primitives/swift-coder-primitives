//
//  Parser.Optionally+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the runtime-optional combinator. `Optionally` is
//  infallible (`Failure == Never`), so a wrapped emission failure cannot
//  propagate; unlike the retired prepend print (which swallowed a possibly
//  partial prepend) the buffer is restored to its pre-attempt state before
//  swallowing — value-checkpoint backtracking.
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Optionally: @retroactive Serializer.`Protocol`
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

    /// Serializes the wrapped output when present; absent values emit nothing.
    @inlinable
    public func serialize(_ output: Wrapped.Output?, into buffer: inout Buffer) {
        guard let output else { return }
        let checkpoint = buffer
        do throws(Wrapped.Failure) {
            try wrapped.serialize(output, into: &buffer)
        } catch {
            buffer = checkpoint
        }
    }
}
