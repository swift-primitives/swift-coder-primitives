//
//  Coder.Protocol+body.swift
//  swift-coder-primitives
//
//  Builder-ambiguity resolution for the unified `body` requirement.
//

internal import Parser_Primitives_Core
public import Serializer_Primitives_Core

extension Coder.`Protocol` {

    /// Satisfies ``Serializer/Protocol``'s `body` requirement on behalf of
    /// every ``Coder/Protocol`` conformer, forwarding to the (unified)
    /// parser-side ``Parser/Protocol/body``.
    ///
    /// ## Why this exists
    ///
    /// `Parser.Protocol` attaches `@Parser.Builder<Input>` to its `body`
    /// requirement and `Serializer.Protocol` attaches
    /// `@Serializer.Builder<Buffer>` to its own. When a conformer of
    /// `Coder.Protocol` declares `var body`, that one declaration would
    /// witness BOTH requirements, and Swift's result-builder inference sees
    /// two distinct builders — "ambiguous result builder inferred for
    /// 'body'". Redeclaring `body` on `Coder.Protocol` only ADDS a third
    /// inference candidate (verified empirically; matches the compiler's
    /// candidate-collection rule).
    ///
    /// The institute's `@_implements` pattern (see the associated-type-trap
    /// write-up and `Experiments/member-import-visibility-body-conflict`)
    /// resolves the merge instead: this stamped forwarder is the witness for
    /// `Serializer.Protocol.body`, so a conformer's own `body` witnesses only
    /// `Parser.Protocol.body` and inference resolves to the single
    /// `Parser.Builder<Input>` — the authoring algebra for bidirectional
    /// bodies, whose combinator products carry `Serializer.Protocol`
    /// conformances via `Coder Parser Primitives`.
    ///
    /// The `_read` coroutine is required: `Body: ~Copyable`, so a plain
    /// `get` forwarding to `body` would consume a borrowed value.
    @_implements(Serializer.`Protocol`, body)
    public var __serializerBody: Body {
        _read { yield body }
    }
}
