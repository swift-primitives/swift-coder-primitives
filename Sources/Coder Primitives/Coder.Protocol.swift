//
//  Coder.Protocol.swift
//  swift-coder-primitives
//
//  Core Coder protocol definition.
//

extension Coder {
    /// A type that can both decode and encode a value.
    ///
    /// Coders are bidirectional transformations — they decode from an input
    /// and encode into a buffer. The key insight is that decode and encode
    /// use **different types**: decode uses a cursor (read-only, with
    /// checkpoint/restore), encode appends to a mutable buffer.
    ///
    /// ## Separate Failure Types
    ///
    /// Decode may fail (malformed input); encode may be infallible
    /// (well-typed value always serializes). `DecodeFailure` and
    /// `EncodeFailure` are independent — use `Never` for infallible
    /// directions.
    ///
    /// ## No Body/Builder
    ///
    /// Unlike `Parser.Protocol` and `Serializer.Protocol`, `Coder.Protocol`
    /// does not include declarative composition via `Body`/`Builder`.
    /// Coders are typically leaf types — one per format x value pair.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct UInt32Coder: Coder.`Protocol` {
    ///     typealias DecodeInput = Binary.Bytes.Input
    ///     typealias EncodeBuffer = [UInt8]
    ///     typealias Output = UInt32
    ///     typealias DecodeFailure = Binary.Bytes.Machine.Fault
    ///     typealias EncodeFailure = Never
    ///
    ///     func decode(_ input: inout Binary.Bytes.Input)
    ///         throws(Binary.Bytes.Machine.Fault) -> UInt32 { ... }
    ///
    ///     func encode(_ output: UInt32, into buffer: inout [UInt8]) { ... }
    /// }
    /// ```
    public protocol `Protocol`<DecodeInput, EncodeBuffer, Output> {
        /// The input type for decoding (typically a cursor or byte span).
        associatedtype DecodeInput: ~Copyable & ~Escapable

        /// The buffer type for encoding (typically a mutable byte array).
        associatedtype EncodeBuffer

        /// The value type that is decoded/encoded.
        associatedtype Output

        /// The error type for decode failures.
        ///
        /// Use `Never` for infallible decoders.
        associatedtype DecodeFailure: Swift.Error & Sendable

        /// The error type for encode failures.
        ///
        /// Use `Never` for infallible encoders.
        associatedtype EncodeFailure: Swift.Error & Sendable

        /// Decodes a value from the input.
        ///
        /// On success, consumes the decoded portion from input and returns
        /// the result. On failure, throws an error.
        ///
        /// - Parameter input: The input to decode from. Modified to reflect consumption.
        /// - Returns: The decoded value.
        /// - Throws: `DecodeFailure` if decoding fails.
        func decode(_ input: inout DecodeInput) throws(DecodeFailure) -> Output

        /// Encodes a value by appending to the buffer.
        ///
        /// On success, appends the encoded representation to buffer.
        /// On failure, throws an error.
        ///
        /// - Parameters:
        ///   - output: The value to encode.
        ///   - buffer: The buffer to append to.
        /// - Throws: `EncodeFailure` if encoding fails.
        func encode(_ output: Output, into buffer: inout EncodeBuffer) throws(EncodeFailure)
    }
}

// MARK: - Buffer-constructing encode convenience

extension Coder.`Protocol` where EncodeBuffer: RangeReplaceableCollection {

    /// Encodes a value, returning a new buffer.
    ///
    /// Creates an empty buffer, encodes the value into it, and returns
    /// the result. For appending to an existing buffer, use
    /// ``encode(_:into:)`` directly.
    ///
    /// - Parameter output: The value to encode.
    /// - Returns: A new buffer containing the encoded representation.
    /// - Throws: `EncodeFailure` if encoding fails.
    @inlinable
    public func encode(_ output: Output) throws(EncodeFailure) -> EncodeBuffer {
        var buffer = EncodeBuffer()
        try encode(output, into: &buffer)
        return buffer
    }
}
