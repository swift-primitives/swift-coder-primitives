//
//  Parser.Many.Separated+Serializer.Protocol.swift
//  swift-coder-primitives
//
//  Forward-order append emission for separated repetition: elements in
//  parse order with the separator between successive elements (the
//  naturally-ordered form of the retired reversed print).
//

public import Parser_Primitives
public import Serializer_Primitives_Core

extension Parser.Many.Separated: @retroactive Serializer.`Protocol`
where
    Element: Serializer.`Protocol`,
    Separator: Serializer.`Protocol`,
    Separator.Output == Void,
    Element.Buffer == Separator.Buffer
{
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

    /// Serializes each element in FORWARD (parse) order, emitting the
    /// separator between successive elements.
    ///
    /// Mirrors the retired print's partial-emission contract: an element or
    /// separator failure stops emission without throwing (the count bounds
    /// are the only failures this combinator reports).
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

        var isFirst = true
        for item in output {
            if !isFirst {
                do throws(Separator.Failure) {
                    try separator.serialize((), into: &buffer)
                } catch {
                    break
                }
            }
            do throws(Element.Failure) {
                try element.serialize(item, into: &buffer)
            } catch {
                break
            }
            isFirst = false
        }
    }
}
