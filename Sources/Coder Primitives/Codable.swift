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
