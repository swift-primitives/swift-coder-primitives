//
//  Parser+Bidirectional.conformances.swift
//  swift-coder-primitives
//
//  The bidirectional refinement declarations for the L1 combinators
//  (documented extension file per the one-type-per-file exception).
//
//  The four combinator refinements previously patched retroactively at L3
//  (B2-17: Always/Take.Two/Skip.First/Skip.Second), plus the builder-entry
//  and conversion-seam propagation rows that the retired
//  swift-parser-primitives Printer files declared
//  (Take.Sequence/OneOf.Sequence/Converted), restated against the
//  Coder-based `Parser.Bidirectional` (`Coder.Protocol where
//  Buffer == Input`).
//

public import Coder_Primitives
public import Parser_Primitives
public import Serializer_Primitives_Core

// MARK: - Leaf bidirectional declaration

// The String literal parser is a full bidirectional leaf: parse consumes the
// literal from a `Substring`, serialize appends it (`Buffer == Input`).
extension Swift.String: Coder.`Protocol`, Parser.Bidirectional {}

// MARK: - The four B2-17 refinements

// A Void-output `Always` round-trips: parse yields `()`, serialize is a no-op.
extension Parser.Always: Coder.`Protocol`, Parser.Bidirectional where Output == Void {}

extension Parser.Take.Two: Coder.`Protocol`, Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {}

extension Parser.Skip.First: Coder.`Protocol`, Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {}

extension Parser.Skip.Second: Coder.`Protocol`, Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {}

// MARK: - Builder-entry and conversion-seam propagation

extension Parser.Take.Sequence: Coder.`Protocol`, Parser.Bidirectional
where Body: Parser.Bidirectional {}

extension Parser.OneOf.Sequence: Coder.`Protocol`, Parser.Bidirectional
where Body: Parser.Bidirectional {}

extension Parser.Converted: Coder.`Protocol`, Parser.Bidirectional
where Upstream: Parser.Bidirectional {}
