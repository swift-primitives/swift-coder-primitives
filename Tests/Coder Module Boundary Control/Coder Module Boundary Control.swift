//
//  Coder Module Boundary Control.swift
//  swift-coder-primitives
//
//  Binding cross-module SIL-verification control for issue #4.
//

public import Coder_Primitives

extension Coder {
    /// A downstream leaf that relies on `Coder.Protocol`'s `Body == Never`
    /// parser-side default witness.
    ///
    /// When `Coder.Witness` is declared in the protocol-defining module,
    /// emitting this second conformance produces a bodiless
    /// `shared [serialized]` read accessor. This target is compiled with
    /// full SIL verification and whole-module optimization, so that old
    /// placement aborts compilation instead of remaining latent on NoAsserts
    /// toolchains.
    public struct Boundary {
        public init() {}
    }
}

extension Coder.Boundary: Coder_Primitives.Coder.`Protocol` {
    public typealias Input = Void
    public typealias Output = Void
    public typealias Buffer = Void
    public typealias Failure = Never
    public typealias Body = Never

    public func parse(_ input: inout Void) {}

    public func serialize(_ output: Void, into buffer: inout Void) {}
}

extension Coder.Boundary {
    /// Exercises both the downstream leaf and the sibling closure witness.
    public static func exercise() {
        var input: Void = ()
        var buffer: Void = ()

        let leaf = Self()
        leaf.parse(&input)
        leaf.serialize((), into: &buffer)

        let witness = Coder.Witness<Void, Void, Void, Never>(
            parse: { _ in () },
            serialize: { _, _ in }
        )
        witness.parse(&input)
        witness.serialize((), into: &buffer)
    }
}
