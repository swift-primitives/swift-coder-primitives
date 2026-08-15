//
//  Coder Witness Dispatch Tests.swift
//  swift-coder-primitives
//
//  Regression tests for the two `body`-witness defect shapes (2026-07-21,
//  ratification-queue item 12). Both defects were INVISIBLE to compile-only
//  gates and to direct (statically-dispatched) calls — they fire only through
//  generic Serializer.Protocol / Parser.Protocol WITNESS dispatch, so every
//  test here goes through a generic function constrained to the protocol.
//
//  Shape 1 — body-declaring conformer (the router shape): the @_implements
//  serializer-side forwarder must reach the conformer's parser-side `body`,
//  not itself (self-recursion → stack exhaustion, SIGBUS).
//
//  Shape 2 — leaf conformer (Body == Never, parse/serialize implemented
//  directly): witness matching must not die on the two identical parent
//  leaf defaults ("multiple matching properties named 'body'"), and the
//  direct implementations must be reached through the witness.
//

import Coder_Parser_Primitives
import Testing

@Suite
struct `Coder Witness Dispatch` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}

    // MARK: Generic dispatch helpers — the load-bearing part.

    private static func serializeViaWitness<S: Serializer.`Protocol`>(
        _ serializer: borrowing S,
        _ value: S.Output,
        into buffer: inout S.Buffer
    ) throws {
        try serializer.serialize(value, into: &buffer)
    }

    private static func parseViaWitness<P: Parser.`Protocol`>(
        _ parser: borrowing P,
        _ input: inout P.Input
    ) throws -> P.Output {
        try parser.parse(&input)
    }

    // MARK: Shape 2 — leaf conformer (the Bearer/Basic/IconPathParser shape).

    struct Leaf: Parser.Bidirectional {}

    @Test
    func `leaf coder serializes and parses through witness dispatch`() throws {
        let coder = Leaf()
        var buffer: Substring = ""
        try Self.serializeViaWitness(coder, (), into: &buffer)
        #expect(buffer == "leaf")
        var cursor = buffer
        try Self.parseViaWitness(coder, &cursor)
        #expect(cursor.isEmpty)
    }

    // MARK: Shape 1 — body-declaring conformer (the router shape).

    struct Router: Parser.Bidirectional {}

    @Test
    func `body-declaring coder serializes through the serializer-side forwarder without recursing`()
        throws
    {
        // The original defect made this call recurse to stack exhaustion —
        // a crash, not an assertion failure. Reaching #expect at all is the
        // regression evidence.
        let coder = Router()
        var buffer: Substring = ""
        try Self.serializeViaWitness(coder, (), into: &buffer)
        #expect(buffer == "leaf")
        var cursor = buffer
        try Self.parseViaWitness(coder, &cursor)
        #expect(cursor.isEmpty)
    }
}

extension `Coder Witness Dispatch`.Leaf {
    typealias Input = Substring
    typealias Buffer = Substring
    typealias Output = Void
    // swift-linter:disable:next unification typealias
    // REASON: Parser.Protocol associated-type witness (Failure); every conformer must declare this exact typealias.
    typealias Failure = Parser.Match.Error

    func parse(_ input: inout Substring) throws(Failure) {
        guard input.hasPrefix("leaf") else {
            throw .literalMismatch(expected: "leaf", found: String(input))
        }
        input.removeFirst(4)
    }

    borrowing func serialize(_ output: Void, into buffer: inout Substring) throws(Failure) {
        buffer += "leaf"
    }
}

extension `Coder Witness Dispatch`.Router {
    // swift-linter:disable:next unification typealias
    // REASON: Parser.Protocol associated-type witness (Input); every conformer must declare this exact typealias.
    typealias Input = Substring
    // swift-linter:disable:next unification typealias
    // REASON: Parser.Protocol associated-type witness (Output); every conformer must declare this exact typealias.
    typealias Output = Void
    // swift-linter:disable:next unification typealias
    // REASON: Parser.Protocol associated-type witness (Failure); every conformer must declare this exact typealias.
    typealias Failure = Parser.Match.Error

    var body: some Parser.Bidirectional<Substring, Void, Parser.Match.Error> {
        `Coder Witness Dispatch`.Leaf()
    }
}
