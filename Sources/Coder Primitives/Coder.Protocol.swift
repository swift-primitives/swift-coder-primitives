//
//  Coder.Protocol.swift
//  swift-coder-primitives
//
//  Hoisted protocol for bidirectional coders.
//

public import Parser_Primitives_Core
public import Serializer_Primitives_Core

/// A type that can both decode (parse) and encode (serialize) a value.
///
/// `Coder.Protocol` (the typealias on ``Coder``) refines ``Parser/Protocol``
/// and ``Serializer/Protocol`` per [FAM-006]: the bidirectional codec IS a
/// parser AND a serializer sharing one value type. Swift's
/// same-name-associated-type unification across the refinement automatically
/// gives:
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
/// Coders are leaf types — `Body == Never` for both inherited `Body` slots.
/// Codecs do not override `body`.
///
/// ## Module-Level Declaration
///
/// This protocol is declared at module scope and hoisted into the ``Coder``
/// namespace via `typealias Protocol = __CoderProtocol`. Module-level
/// declaration is required because Swift forbids protocols nested in
/// generic contexts. Implementers SHOULD reference `Coder.Protocol` rather
/// than this hoisted name.
public protocol __CoderProtocol: Parser.`Protocol`, Serializer.`Protocol` { }
