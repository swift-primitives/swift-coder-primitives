//
//  Coder.Codable.swift
//  swift-coder-primitives
//
//  Canonical attachment protocol for bidirectional coding.
//

public import Parser_Primitives_Core
public import Serializer_Primitives_Core

extension Coder {
    /// A type that has a canonical coder.
    ///
    /// Conforming types declare their canonical ``Coder`` and provide a static
    /// accessor to obtain it. This enables generic algorithms to discover the
    /// coder for any `Codable` type.
    ///
    /// `Coder.Codable` is nested under the ``Coder`` namespace per
    /// [API-NAME-001]; a top-level `Codable` would shadow `Swift.Codable`
    /// at every re-exporting consumer.
    ///
    /// `Codable` is independent of `Parseable` and `Serializable` — a Coder
    /// handles both directions internally. Forcing decomposition into separate
    /// Parser + Serializer is artificial for bidirectional types.
    ///
    /// ```swift
    /// extension UInt32: Coder.Codable {
    ///     static var coder: Binary.UInt32Coder { .init() }
    /// }
    /// ```
    public protocol Codable {
        /// The canonical coder type for this value.
        associatedtype Coder: Coder_Primitives.Coder.`Protocol`

        /// The canonical coder instance.
        static var coder: Coder { get }
    }
}

// MARK: - Instance-level encode

extension Coder.Codable where Coder.Output == Self {

    /// Encodes this value by appending to a buffer.
    ///
    /// - Parameter buffer: The buffer to append to.
    /// - Throws: `Coder.Failure` if encoding fails.
    @inlinable
    public func encode(into buffer: inout Coder.Buffer) throws(Coder.Failure) {
        try Self.coder.serialize(self, into: &buffer)
    }

    /// Decodes a value from the input using the canonical coder.
    ///
    /// - Parameter input: The input to decode from. Modified to reflect consumption.
    /// - Throws: `Coder.Failure` if decoding fails.
    @inlinable
    public init(decoding input: inout Coder.Input) throws(Coder.Failure) {
        self = try Self.coder.parse(&input)
    }
}

// MARK: - Buffer-constructing encode

extension Coder.Codable where Coder.Output == Self, Coder.Buffer: RangeReplaceableCollection {

    /// Encodes this value, returning a new buffer.
    ///
    /// - Returns: A new buffer containing the encoded representation.
    /// - Throws: `Coder.Failure` if encoding fails.
    @inlinable
    public func encoded() throws(Coder.Failure) -> Coder.Buffer {
        try Self.coder.serialize(self)
    }
}
