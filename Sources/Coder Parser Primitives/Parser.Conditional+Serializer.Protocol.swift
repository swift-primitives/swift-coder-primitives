//
//  Parser.Conditional+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission for the builder's if-else branch combinator.
//

public import Either_Primitives
public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Conditional: @retroactive Serializer.`Protocol`
where First: Serializer.`Protocol`, Second: Serializer.`Protocol`, First.Buffer == Second.Buffer {
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

    /// Serializes using whichever branch this value holds.
    @inlinable
    public func serialize(
        _ output: Output,
        into buffer: inout Buffer
    ) throws(Either<First.Failure, Second.Failure>) {
        switch self {
        case .first(let serializer):
            do throws(First.Failure) {
                try serializer.serialize(output, into: &buffer)
            } catch {
                throw .left(error)
            }

        case .second(let serializer):
            do throws(Second.Failure) {
                try serializer.serialize(output, into: &buffer)
            } catch {
                throw .right(error)
            }
        }
    }
}
