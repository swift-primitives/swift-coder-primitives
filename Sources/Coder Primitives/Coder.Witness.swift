//
//  Coder.Witness.swift
//  swift-coder-primitives
//

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
    /// let uint16BE = Coder.Witness<Byte.Input, UInt16, [UInt8], Binary.Machine.Fault>(
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
    > {
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
    }
}

extension Coder.Witness: Coder.`Protocol` {
    /// A leaf coder has no composed body.
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

extension Coder {
    /// A closure-backed coder that cannot fail.
    ///
    /// `Coder.Pure<Input, Output, Buffer>` is shorthand for
    /// `Coder.Witness<Input, Output, Buffer, Never>`. Use it to elide the
    /// `Failure` type argument when the coder is infallible in both
    /// directions.
    ///
    /// ```swift
    /// let c = Coder.Pure<Substring, Int, [UInt8]>(
    ///     parse: { input in /* ... */ },
    ///     serialize: { value, buffer in /* ... */ }
    /// )
    /// ```
    public typealias Pure<Input, Output, Buffer> = Witness<Input, Output, Buffer, Never>
    where Input: ~Copyable & ~Escapable
}
