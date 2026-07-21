//
//  Parser.Converted+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Append emission through the conversion seam: un-apply the conversion,
//  then serialize with the upstream. The seam is order-agnostic, so the
//  shape is identical to the retired print — only the emission discipline
//  (append) differs.
//

public import Either_Primitives
public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Converted: @retroactive Serializer.`Protocol`
where Upstream: Serializer.`Protocol` {
    /// The buffer type this serializer appends to.
    public typealias Buffer = Upstream.Buffer

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

    /// Un-applies the conversion, then serializes with the upstream.
    @inlinable
    public func serialize(
        _ output: Output,
        into buffer: inout Buffer
    ) throws(Either<Upstream.Failure, Downstream.Failure>) {
        let upstreamOutput: Upstream.Output
        do throws(Downstream.Failure) {
            upstreamOutput = try downstream.unapply(output)
        } catch {
            throw .right(error)
        }
        do throws(Upstream.Failure) {
            try upstream.serialize(upstreamOutput, into: &buffer)
        } catch {
            throw .left(error)
        }
    }
}
