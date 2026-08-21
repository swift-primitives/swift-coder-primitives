public import Parser_Primitives_Core
public import Serializer_Primitives_Core

extension Parser {

    public protocol Bidirectional<Input, Output, Failure>: Coder.`Protocol`, ~Copyable
    where Buffer == Input {}
}
