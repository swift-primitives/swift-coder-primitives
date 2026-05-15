//
//  Coder.swift
//  swift-coder-primitives
//
//  Namespace for bidirectional coding primitives.
//
//  The family-as-enum-namespace + nested-Witness shape (validated in
//  `family-as-enum-namespace-witness-nested`, CONFIRMED 6/6) restores the
//  enum-namespace at the root. The closure-backed witness lives as one
//  combinator type among many, nested under the namespace as
//  ``Coder/Witness``.
//

internal import Parser_Primitives_Core
internal import Serializer_Primitives_Core

/// Namespace for bidirectional coding primitives.
///
/// `Coder.Protocol` (the nested protocol) is the canonical surface for
/// bidirectional codecs; it refines ``Parser/Protocol`` and
/// ``Serializer/Protocol`` so a single conformer is both a parser and
/// a serializer with same-name unified `Input`/`Output`/`Buffer`/`Failure`.
///
/// ``Coder/Witness`` is the closure-backed conformer used for ad-hoc
/// witnesses; additional combinator types nest under this namespace.
public enum Coder {}

extension Coder {

    /// A closure-backed bidirectional coder — the canonical witness for
    /// ``Coder/Protocol``.
    ///
    /// `Coder.Witness` stores a parse closure and a serialize closure and
    /// exposes both as the methods required by ``Coder/Protocol`` (which
    /// refines ``Parser/Protocol`` and ``Serializer/Protocol``).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let uint16BE = Coder.Witness<Binary.Bytes.Input, UInt16, [UInt8], Binary.Bytes.Machine.Fault>(
    ///     parse: { input in
    ///         let hi = try input.advance()
    ///         let lo = try input.advance()
    ///         return UInt16(hi) << 8 | UInt16(lo)
    ///     },
    ///     serialize: { value, buffer in
    ///         buffer.append(UInt8(value >> 8))
    ///         buffer.append(UInt8(truncatingIfNeeded: value))
    ///     }
    /// )
    /// ```
    ///
    /// ## Leaf Witness
    ///
    /// `Coder.Witness` is a leaf conformer: it implements ``parse(_:)`` and
    /// ``serialize(_:into:)`` directly via stored closures rather than
    /// composing through a `body`.
    public struct Witness<
        Input: ~Copyable & ~Escapable,
        Output,
        Buffer,
        Failure: Swift.Error
    >: Coder.`Protocol` {
        @usableFromInline
        var _parse: (inout Input) throws(Failure) -> Output

        @usableFromInline
        var _serialize: (Output, inout Buffer) throws(Failure) -> Void

        /// Creates a coder witness from parse and serialize closures.
        ///
        /// - Parameters:
        ///   - parse: Parses an `Output` value from the input cursor.
        ///   - serialize: Serializes an `Output` value by appending to the buffer.
        @inlinable
        public init(
            parse: @escaping (inout Input) throws(Failure) -> Output,
            serialize: @escaping (Output, inout Buffer) throws(Failure) -> Void
        ) {
            self._parse = parse
            self._serialize = serialize
        }

        public typealias Body = Never

        /// Leaf coder witnesses do not have a body — ``parse(_:)`` and
        /// ``serialize(_:into:)`` are implemented directly via stored closures.
        ///
        /// An explicit getter is required because both ``Parser/Protocol`` and
        /// ``Serializer/Protocol`` provide a default `body: Never` getter in
        /// their `where Body == Never` extensions; without this override Swift
        /// cannot pick between the two inherited candidates.
        @inlinable
        public var body: Never {
            borrowing get {
                return fatalError("Coder.Witness is a leaf — parse(_:) and serialize(_:into:) are implemented directly via stored closures")
            }
        }

        /// Parses an `Output` value from the input.
        ///
        /// Delegates to the stored parse closure.
        @inlinable
        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            try _parse(&input)
        }

        /// Serializes an `Output` value by appending to the buffer.
        ///
        /// Delegates to the stored serialize closure.
        @inlinable
        public borrowing func serialize(_ value: Output, into buffer: inout Buffer) throws(Failure) {
            try _serialize(value, &buffer)
        }
    }
}
