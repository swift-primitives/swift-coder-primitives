# Choosing Between `Parser.Bidirectional` and `Coder.Protocol`

When a domain has both decode and encode directions, two ecosystem
shapes are available: `Parser.Bidirectional` from
`swift-parser-primitives`, and `Coder.Protocol` from this package. They
look superficially similar — both round-trip a value — but they model
fundamentally different problems.

## When to use `Parser.Bidirectional`

Reach for `Parser.Bidirectional` when:

- **Same `Input` type for both directions.** Decode reads from `Input`;
  encode produces `Input`. The canonical case is text-format
  round-tripping where both sides operate on `Substring` (or a similar
  `Collection.Slice` over the same element type).
- **Shared `Failure` type.** A single typed error covers both directions
  — there is no meaningful asymmetry between "malformed on read" and
  "cannot represent on write."
- **Composable via `Body`/`Builder`.** Bidirectional parsers participate
  in the declarative parser builder DSL — they map, combine, and nest
  alongside ordinary parsers.

Example domains: URL component round-tripping, simple text grammars,
identifier formats, RFC token round-trips where both directions trade in
the same character space.

## When to use `Coder.Protocol`

Reach for `Coder.Protocol` when:

- **Different types per direction.** Decode reads from a cursor type
  optimized for non-copying scan (e.g., `Span<UInt8>` advancing through
  a byte buffer); encode appends to a mutable heap-backed buffer (e.g.,
  `[UInt8]`). The asymmetry is structural, not incidental.
- **Separate `DecodeFailure` and `EncodeFailure`.** Decode may fail on
  malformed input; encode may be infallible for well-typed values. The
  two error spaces are independent — forcing them through a single
  `Failure` type loses precision.
- **Leaf shape.** A coder is the format-times-value unit; it does not
  compose via a body builder. Combinators belong on parsers and
  serializers, not on coders.

The protocol's doc-comment philosophy on `Codable.swift:17-19` captures
the design intent: *"`Codable` is independent of `Parseable` and
`Serializable` — a Coder handles both directions internally. Forcing
decomposition into separate Parser + Serializer is artificial for
bidirectional types."*

Canonical example: binary format codecs. JSON's `UInt32Coder` decodes
from a `Byte.Input` cursor and encodes into a `[UInt8]` heap
buffer — distinct types, distinct failure modes, no shared body.

## The boundary in one line

If decode and encode share `Input`, `Failure`, and benefit from
declarative composition: `Parser.Bidirectional`.

If decode and encode use different types, have independent failure
modes, and are leaf format-times-value units: `Coder.Protocol`.
