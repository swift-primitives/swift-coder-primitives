//
//  Parser.Bidirectional.swift
//  swift-coder-primitives
//
//  The law-carrying constrained form of `Coder.Protocol`.
//

public import Parser_Primitives_Core
public import Serializer_Primitives_Core

extension Parser {
    /// A bidirectional parser: a ``Coder/Protocol`` whose emission buffer is
    /// the parse input type.
    ///
    /// `Parser.Bidirectional` is the law-carrying constrained form of
    /// ``Coder/Protocol``: `serialize` appends, in FORWARD (parse) order, the
    /// exact representation `parse` consumes.
    ///
    /// ## Round-Trip Laws
    ///
    /// A well-formed bidirectional parser satisfies:
    /// ```
    /// parse(serialize(value)) == value       // emit then parse recovers the value
    /// serialize(parse(input)) == input       // parse then emit recovers the input
    /// ```
    /// and the non-empty-rest law: serializing after an already-emitted prefix
    /// leaves the prefix untouched; parsing the whole buffer yields the
    /// prefix's value(s) followed by this parser's value.
    ///
    /// ## History
    ///
    /// This protocol replaces the retired `Parser.Printer` prepend algebra
    /// (swift-parser-primitives, retired after the coder-unification spike
    /// verdict GREEN): forward-order APPEND emission through
    /// ``Serializer/Protocol`` is byte-equal to reverse-order prepend printing,
    /// with backtracking expressible as a value-copy checkpoint of the buffer.
    public protocol Bidirectional<Input, Output, Failure>: Coder.`Protocol`
    where Buffer == Input {}
}
