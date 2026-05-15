//
//  Coder.swift
//  swift-coder-primitives
//
//  Closure-backed bidirectional coder witness.
//

internal import Parser_Primitives_Core
internal import Serializer_Primitives_Core

/// A closure-backed bidirectional coder witness.
///
/// `Coder` stores a parse closure and a serialize closure and exposes both as
/// the methods required by ``Coder/Protocol`` (which refines
/// ``Parser/Protocol`` and ``Serializer/Protocol``).
///
/// ## Example
///
/// ```swift
/// let uint16BE = Coder<Binary.Bytes.Input, UInt16, [UInt8], Binary.Bytes.Machine.Fault>(
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
/// `Coder` is a leaf conformer: `Body == Never`. The default `body` getter
/// inherited from ``Parser/Protocol`` and ``Serializer/Protocol`` traps if
/// invoked.
public struct Coder<
    Input: ~Copyable & ~Escapable,
    Output,
    Buffer,
    Failure: Swift.Error
>: __CoderProtocol {
    @usableFromInline
    var _parse: (inout Input) throws(Failure) -> Output

    @usableFromInline
    var _serialize: (Output, inout Buffer) throws(Failure) -> Void

    /// Creates a coder from parse and serialize closures.
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
}

// MARK: - Body == Never (leaf conformer per [API-IMPL-020])

extension Coder where Input: ~Copyable & ~Escapable {
    public typealias Body = Never

    /// Leaf coders do not have a body — ``parse(_:)`` and ``serialize(_:into:)``
    /// are implemented directly via stored closures.
    ///
    /// An explicit getter is required because both ``Parser/Protocol`` and
    /// ``Serializer/Protocol`` provide a default `body: Never` getter in their
    /// `where Body == Never` extensions; without this override Swift cannot
    /// pick between the two inherited candidates.
    @inlinable
    public var body: Never {
        borrowing get {
            fatalError("Coder is a leaf witness — parse(_:) and serialize(_:into:) are implemented directly via stored closures")
        }
    }
}

// MARK: - Coder.Protocol Witness Methods

extension Coder where Input: ~Copyable & ~Escapable {
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
    public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
        try _serialize(output, &buffer)
    }
}

// MARK: - Protocol Typealias Hoist

extension Coder where Input: ~Copyable & ~Escapable {
    /// The bidirectional coder protocol, hoisted from module scope.
    ///
    /// `Coder.Protocol` is the consumer-facing path to ``__CoderProtocol``;
    /// module-level declaration is required because Swift forbids protocols
    /// nested in generic contexts.
    public typealias `Protocol` = __CoderProtocol
}
