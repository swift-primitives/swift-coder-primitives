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
