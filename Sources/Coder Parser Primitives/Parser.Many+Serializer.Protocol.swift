//
//  Parser.Many+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Forward-order append emission for repetition (the retired print iterated
//  `output.reversed()`; serialize iterates in parse order).
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Many: @retroactive Serializer.`Protocol`
where Element: Serializer.`Protocol` {
    /// The buffer type this serializer appends to.
    public typealias Buffer = Element.Buffer

    /// Explicit leaf body: both `Parser.Protocol` and `Serializer.Protocol`
    /// provide a `Body == Never` default getter; without this override Swift
    /// cannot pick between the two inherited candidates (the Coder.Witness
    /// precedent).
    @inlinable
    public var body: Never {
        borrowing get {
            return fatalError("leaf combinator — serialize(_:into:) is implemented directly")
        }
    }

    /// Serializes each element in FORWARD (parse) order.
    ///
    /// Mirrors the retired print's partial-emission contract: an element
    /// failure stops emission without throwing (the count bounds are the
    /// only failures this combinator reports).
    @inlinable
    public func serialize(
        _ output: [Element.Output],
        into buffer: inout Buffer
    ) throws(Parser.Many<Input, Element>.Error) {
        if output.count < minimum {
            throw .countTooLow(expected: minimum, got: output.count)
        }
        if maximum < .max, output.count > maximum {
            throw .countTooHigh(expected: maximum, got: output.count)
        }

        for item in output {
            do throws(Element.Failure) {
                try element.serialize(item, into: &buffer)
            } catch {
                break
            }
        }
    }
}
