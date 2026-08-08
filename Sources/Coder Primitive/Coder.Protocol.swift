//
//  Coder.Protocol.swift
//  swift-coder-primitives
//
//  Core Coder protocol definition.
//

public import Parser_Primitives_Core
public import Serializer_Primitives_Core

extension Coder {
    /// A type that can both decode (parse) and encode (serialize) a value.
    ///
    /// `Coder.Protocol` refines ``Parser/Protocol`` and ``Serializer/Protocol``
    /// per [FAM-006]: the bidirectional codec IS a parser AND a serializer
    /// sharing one value type. Swift's same-name-associated-type unification
    /// across the refinement automatically gives:
    ///
    /// - `Input`   — inherited from ``Parser/Protocol``
    /// - `Output`  — inherited (unified) from both refined protocols
    /// - `Buffer`  — inherited from ``Serializer/Protocol``
    /// - `Failure` — inherited (unified) from both refined protocols; codecs
    ///   with distinct decode/encode failures populate this with
    ///   `Either<DecodeFailure, EncodeFailure>` from `Either_Primitives`
    ///   (the `Either<X, Never>` collapse via `Either+Never.swift` makes
    ///   one-direction-infallible codecs free at call sites).
    ///
    /// ## No Body/Builder
    ///
    /// Coders are leaf types — `Body == Never` for both inherited `Body`
    /// slots. Codecs do not override `body`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct UInt32Coder: Coder.`Protocol` {
    ///     typealias Input   = Byte.Input
    ///     typealias Buffer  = [UInt8]
    ///     typealias Output  = UInt32
    ///     typealias Failure = Binary.Machine.Fault
    ///
    ///     func parse(_ input: inout Byte.Input)
    ///         throws(Binary.Machine.Fault) -> UInt32 { ... }
    ///
    ///     func serialize(_ output: UInt32, into buffer: inout [UInt8]) { ... }
    /// }
    /// ```
    public protocol `Protocol`<Input, Output, Buffer, Failure>:
        Parser.`Protocol`, Serializer.`Protocol`, ~Copyable
    {}
}
