public import Coder_Primitives
public import Parser_Primitives
import Serializer_Primitives_Core

extension Swift.String: Coder.`Protocol`, Parser.Bidirectional {

    public typealias Body = Never
}

extension Parser.Always: Coder.`Protocol`, Parser.Bidirectional where Output == Void {

    public typealias Body = Never
}

extension Parser.Take.Two: Coder.`Protocol`, Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {

    public typealias Body = Never
}

extension Parser.Skip.First: Coder.`Protocol`, Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {

    public typealias Body = Never
}

extension Parser.Skip.Second: Coder.`Protocol`, Parser.Bidirectional
where P0: Parser.Bidirectional, P1: Parser.Bidirectional {

    public typealias Body = Never
}

extension Parser.Take.Sequence: Coder.`Protocol`, Parser.Bidirectional
where Body: Parser.Bidirectional {

    public typealias Body = Never
}

extension Parser.OneOf.Sequence: Coder.`Protocol`, Parser.Bidirectional
where Body: Parser.Bidirectional {

    public typealias Body = Never
}

extension Parser.Converted: Coder.`Protocol`, Parser.Bidirectional
where Upstream: Parser.Bidirectional {

    public typealias Body = Never
}
