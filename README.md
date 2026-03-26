# uniq

[![CI](https://github.com/akvilary/uniq/actions/workflows/ci.yml/badge.svg)](https://github.com/akvilary/uniq/actions/workflows/ci.yml)
[![Nim version](https://img.shields.io/badge/Nim-%E2%89%A5%202.0.0-orange?logo=nim)](https://nim-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

RFC 9562 UUID library for Nim. Stack-allocated 16-byte UUIDs, versions 1, 3, 4, 5, 6, 7, 8.

## Installation

```
nimble install uniq
```

Or add to your `.nimble` file:

```nim
requires "uniq >= 0.1.0"
```

## Quick start

All generation functions return `Uuid` — a stack-allocated 16-byte object (`distinct array[16, byte]`), not a string. Use `$` to convert to string representation:

```nim
import uniq

let id: Uuid = uuid7()    # returns Uuid object (16 bytes on the stack)
echo $id                   # "01937b1a-4e5c-7f2a-b3d1-4a8e9c0f1234"
echo id.bytes              # raw array[16, byte]
echo sizeof(id)            # 16
```

## UUID versions

### v4 — Random

```nim
let id: Uuid = uuid4()
echo $id  # e.g. "f47ac10b-58cc-4372-a567-0e02b2c3d479"
```

Cryptographically random, 122 random bits. The most common general-purpose UUID.

### v7 — Time-based sortable (recommended for databases)

```nim
let a: Uuid = uuid7()
sleep(1)
let b: Uuid = uuid7()
assert a < b  # Uuid objects are lexicographically sortable by creation time
```

48-bit Unix millisecond timestamp + 74 random bits. Sortable, modern replacement for v1.

### v1 — Time-based (Gregorian epoch)

```nim
let id: Uuid = uuid1()
```

60-bit timestamp (100ns intervals since 1582-10-15) + random node ID.

### v6 — Reordered time-based (sortable v1)

```nim
let id: Uuid = uuid6()
assert uuid6() <= uuid6()  # sortable
```

Same timestamp as v1 but with bytes reordered for lexicographic sorting.

### v3 — Name-based (MD5)

```nim
let id: Uuid = uuid3(NamespaceDNS, "www.example.com")
assert $id == "5df41881-3aed-3515-88a7-2f4a814cf09e"
```

Deterministic: same namespace + name always produces the same UUID.

### v5 — Name-based (SHA-1)

```nim
let id: Uuid = uuid5(NamespaceDNS, "www.example.com")
assert $id == "2ed6657d-e927-568b-95e1-2665a8aea6a2"
```

Like v3 but uses SHA-1. Preferred over v3 for new applications.

### v8 — Custom

```nim
let id: Uuid = uuid8(myBytes)            # from array[16, byte]
let id2: Uuid = uuid8(highBits, lowBits) # from two uint64
```

User provides 122 custom bits; version and variant bits are set automatically.

## Predefined namespaces

For use with `uuid3` and `uuid5`:

| Constant | Value |
|---|---|
| `NamespaceDNS` | `6ba7b810-9dad-11d1-80b4-00c04fd430c8` |
| `NamespaceURL` | `6ba7b811-9dad-11d1-80b4-00c04fd430c8` |
| `NamespaceOID` | `6ba7b812-9dad-11d1-80b4-00c04fd430c8` |
| `NamespaceX500` | `6ba7b814-9dad-11d1-80b4-00c04fd430c8` |

## Creating from integer

Like Python's `UUID(int=N)` — stores the raw integer without setting version/variant bits:

```nim
let a: Uuid = toUuid(1)
echo $a  # "00000000-0000-0000-0000-000000000001"

let b: Uuid = toUuid(255)
echo $b  # "00000000-0000-0000-0000-0000000000ff"

# Also works with uint64
let c: Uuid = toUuid(0xDEADBEEF'u64)

# Full 128 bits via two uint64 (hi, lo)
let d: Uuid = toUuid(1'u64, 0'u64)
echo $d  # "00000000-0000-0001-0000-000000000000"

# Extract the integer back
echo a.lo  # 1
echo a.hi  # 0
```

## Parsing and formatting

```nim
# String -> Uuid
let id: Uuid = parseUuid("6ba7b810-9dad-11d1-80b4-00c04fd430c8")

# Uuid -> String
let s: string = $id  # "6ba7b810-9dad-11d1-80b4-00c04fd430c8"

# Non-raising variant
var u: Uuid
if tryParseUuid("6ba7b810-9dad-11d1-80b4-00c04fd430c8", u):
  echo $u
```

## Inspecting UUIDs

```nim
let id: Uuid = uuid7()

id.version   # uver7 (UuidVersion enum)
id.variant   # uvarRFC9562 (UuidVariant enum)
id.isNil     # false
id.isMax     # false
id.bytes     # array[16, byte] — raw byte access
```

## Stack-allocated, zero heap allocation

`Uuid` is `distinct array[16, byte]` — 16 bytes on the stack, no heap allocation. Supports comparison operators (`==`, `<`, `>`, `<=`, `>=`), hashing (works with `Table` and `HashSet`), and sorting.

```nim
import std/[sets, algorithm]

var ids: HashSet[Uuid]
ids.incl(uuid4())

var list = @[uuid7(), uuid7(), uuid7()]
list.sort()  # v7 UUIDs sort by creation time
```

## Special UUIDs

```nim
NilUuid  # 00000000-0000-0000-0000-000000000000
MaxUuid  # ffffffff-ffff-ffff-ffff-ffffffffffff
```

## License

MIT
