//
//  Codable.swift
//  swift-coder-primitives
//
//  Canonical attachment protocol for bidirectional coding.
//

/// A type that has a canonical coder.
///
/// Conforming types declare their canonical ``Coder`` and provide a static
/// accessor to obtain it. This enables generic algorithms to discover the
/// coder for any `Codable` type.
///
/// This protocol shadows `Swift.Codable`. Types that need Swift's built-in
/// `Codable` should use `Swift.Codable` explicitly.
///
/// `Codable` is independent of `Parseable` and `Serializable` — a Coder
/// handles both directions internally. Forcing decomposition into separate
/// Parser + Serializer is artificial for bidirectional types.
///
/// ```swift
/// extension UInt32: Codable {
///     static var coder: Binary.UInt32Coder { .init() }
/// }
/// ```
public protocol Codable {
    /// The canonical coder type for this value.
    associatedtype Coder: Coder_Primitives.Coder.`Protocol`

    /// The canonical coder instance.
    static var coder: Coder { get }
}

// MARK: - Instance-level encode

extension Codable where Coder.Output == Self {

    /// Encodes this value by appending to a buffer.
    ///
    /// - Parameter buffer: The buffer to append to.
    /// - Throws: `Coder.EncodeFailure` if encoding fails.
    @inlinable
    public func encode(into buffer: inout Coder.EncodeBuffer) throws(Coder.EncodeFailure) {
        try Self.coder.encode(self, into: &buffer)
    }

    /// Decodes a value from the input using the canonical coder.
    ///
    /// - Parameter input: The input to decode from. Modified to reflect consumption.
    /// - Throws: `Coder.DecodeFailure` if decoding fails.
    @inlinable
    public init(decoding input: inout Coder.DecodeInput) throws(Coder.DecodeFailure) {
        self = try Self.coder.decode(&input)
    }
}

// MARK: - Buffer-constructing encode

extension Codable where Coder.Output == Self, Coder.EncodeBuffer: RangeReplaceableCollection {

    /// Encodes this value, returning a new buffer.
    ///
    /// - Returns: A new buffer containing the encoded representation.
    /// - Throws: `Coder.EncodeFailure` if encoding fails.
    @inlinable
    public func encoded() throws(Coder.EncodeFailure) -> Coder.EncodeBuffer {
        try Self.coder.encode(self)
    }
}
