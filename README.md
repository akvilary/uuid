# uuid

RFC 9562 UUID library for Nim. Stack-allocated 16-byte UUIDs, versions 1, 3, 4, 5, 6, 7, 8.

## Installation

```
nimble install https://github.com/akvilary/uuid.git
```

Or add to your `.nimble` file:

```nim
requires "https://github.com/akvilary/uuid.git >= 0.1.0"
```

## Quick start

```nim
import uuid

let id = uuidv7()
echo id  # e.g. "01937b1a-4e5c-7f2a-b3d1-4a8e9c0f1234"
```

## UUID versions

### v4 — Random

```nim
let id = uuidv4()
```

Cryptographically random, 122 random bits. The most common general-purpose UUID.

### v7 — Time-based sortable (recommended for databases)

```nim
let a = uuidv7()
sleep(1)
let b = uuidv7()
assert a < b  # lexicographically sortable by creation time
```

48-bit Unix millisecond timestamp + 74 random bits. Sortable, modern replacement for v1.

### v1 — Time-based (Gregorian epoch)

```nim
let id = uuidv1()
```

60-bit timestamp (100ns intervals since 1582-10-15) + random node ID.

### v6 — Reordered time-based (sortable v1)

```nim
let id = uuidv6()
assert uuidv6() <= uuidv6()  # sortable
```

Same timestamp as v1 but with bytes reordered for lexicographic sorting.

### v3 — Name-based (MD5)

```nim
let id = uuidv3(NamespaceDNS, "www.example.com")
assert $id == "5df41881-3aed-3515-88a7-2f4a814cf09e"
```

Deterministic: same namespace + name always produces the same UUID.

### v5 — Name-based (SHA-1)

```nim
let id = uuidv5(NamespaceDNS, "www.example.com")
assert $id == "2ed6657d-e927-568b-95e1-2665a8aea6a2"
```

Like v3 but uses SHA-1. Preferred over v3 for new applications.

### v8 — Custom

```nim
let id = uuidv8(myBytes)            # from array[16, byte]
let id2 = uuidv8(highBits, lowBits) # from two uint64
```

User provides 122 custom bits; version and variant bits are set automatically.

## Predefined namespaces

For use with `uuidv3` and `uuidv5`:

| Constant | Value |
|---|---|
| `NamespaceDNS` | `6ba7b810-9dad-11d1-80b4-00c04fd430c8` |
| `NamespaceURL` | `6ba7b811-9dad-11d1-80b4-00c04fd430c8` |
| `NamespaceOID` | `6ba7b812-9dad-11d1-80b4-00c04fd430c8` |
| `NamespaceX500` | `6ba7b814-9dad-11d1-80b4-00c04fd430c8` |

## Parsing and formatting

```nim
let id = parseUuid("6ba7b810-9dad-11d1-80b4-00c04fd430c8")
echo id  # "6ba7b810-9dad-11d1-80b4-00c04fd430c8"

# Non-raising variant
var u: Uuid
if tryParseUuid("6ba7b810-9dad-11d1-80b4-00c04fd430c8", u):
  echo u
```

## Inspecting UUIDs

```nim
let id = uuidv7()

id.version   # uvV7
id.variant   # uvRFC9562
id.isNil     # false
id.isMax     # false
id.bytes     # array[16, byte]
```

## Stack-allocated, zero heap allocation

`Uuid` is `distinct array[16, byte]` — 16 bytes on the stack, no heap allocation. Supports comparison operators (`==`, `<`, `>`, `<=`, `>=`), hashing (works with `Table` and `HashSet`), and sorting.

```nim
import std/[sets, algorithm]

var ids: HashSet[Uuid]
ids.incl(uuidv4())

var list = @[uuidv7(), uuidv7(), uuidv7()]
list.sort()  # v7 UUIDs sort by creation time
```

## Special UUIDs

```nim
NilUuid  # 00000000-0000-0000-0000-000000000000
MaxUuid  # ffffffff-ffff-ffff-ffff-ffffffffffff
```

## License

MIT
