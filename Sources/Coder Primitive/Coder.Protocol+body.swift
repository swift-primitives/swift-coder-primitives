//
//  Coder.Protocol+body.swift
//  swift-coder-primitives
//
//  Builder-ambiguity resolution for the unified `body` requirement.
//

// Public rather than internal: `__parserBody` below is `@inlinable` as part of
// the nightly-toolchain workaround, and inlinable bodies cannot reference
// declarations through an internal import.
public import Parser_Primitives_Core
public import Serializer_Primitives_Core

extension Parser.`Protocol` where Self: ~Copyable {

    // swift-format-ignore: AlwaysUseLowerCamelCase
    /// Parser-side accessor for `body`.
    ///
    /// In this extension only
    /// `Parser.Protocol.body` is in scope, so the unqualified reference
    /// binds statically to the conformer's declaration — an unqualified
    /// `body` inside the `Coder.Protocol` forwarder below resolves to the
    /// SERIALIZER requirement (whose witness is that forwarder itself) and
    /// recurses until stack exhaustion.
    /// `@inlinable` is part of the nightly-toolchain workaround below: a
    /// non-serialized cross-module accessor in this forwarding chain recreates
    /// the bodiless `shared [serialized]` reference the SIL verifier rejects.
    @inlinable
    @usableFromInline
    internal var __parserBody: Body {
        _read { yield body }
    }
}

extension Coder.`Protocol` where Self: ~Copyable {

    // swift-format-ignore: AlwaysUseLowerCamelCase
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
    /// `@inlinable` works around a Swift toolchain defect (6.4.x-nightly and
    /// main-nightly): downstream modules reference this cross-module accessor
    /// as a bodiless `shared [serialized]` function and the SIL verifier
    /// aborts ("public/package/shared function must have a body"). Serializing
    /// the body removes the bodiless reference. Tracked:
    /// swift-primitives/swift-coder-primitives#3; reproducer:
    /// swift-institute/Issues#88.
    @inlinable
    @_implements(Serializer.`Protocol`,body)
    public var __serializerBody: Body {
        _read { yield __parserBody }
    }
}

extension Coder.`Protocol` where Self: ~Copyable, Body == Never {

    // swift-format-ignore: AlwaysUseLowerCamelCase
    /// Pins the PARSER-side `body` witness for leaf coders (`Body == Never`,
    /// `parse`/`serialize` implemented directly).
    ///
    /// Without this, witness
    /// matching sees TWO extension members named `body` of type `Never` —
    /// `Parser.Protocol`'s leaf default and `Serializer.Protocol`'s leaf
    /// default — and fails with "multiple matching properties named 'body'".
    /// The serializer side is already pinned by the forwarder above.
    /// Attributes do not repair the `Body == Never` default-witness verifier
    /// defect. The defining `Coder_Primitive` module therefore contains no
    /// leaf conformer; `Coder.Witness` lives in `Coder_Witness_Primitives`.
    /// Tracked: swift-primitives/swift-coder-primitives#4; reproducer:
    /// swift-institute/Issues/swift-issue-noncopyable-assoctype-never-bodyless-witness.
    @inlinable
    @_implements(Parser.`Protocol`,body)
    public var __parserLeafBody: Never {
        borrowing get {
            fatalError("\(Self.self) is a leaf coder — implement parse(_:) directly")
        }
    }
}
