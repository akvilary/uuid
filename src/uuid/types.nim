## Core UUID type, constants, and operators.

import std/hashes

type
  Uuid* = distinct array[16, byte]
    ## A universally unique identifier stored as 16 bytes on the stack.
    ## Byte layout follows RFC 9562 network byte order (big-endian).

  UuidVersion* = enum
    uvNone = 0
    uvV1 = 1
    uvV2 = 2
    uvV3 = 3
    uvV4 = 4
    uvV5 = 5
    uvV6 = 6
    uvV7 = 7
    uvV8 = 8

  UuidVariant* = enum
    uvNCS        ## NCS backward compatibility (0xx)
    uvRFC9562    ## RFC 9562 / RFC 4122 (10x)
    uvMicrosoft  ## Microsoft backward compatibility (110)
    uvFuture     ## Reserved for future (111)

const
  NilUuid* = Uuid([0x00'u8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])

  MaxUuid* = Uuid([0xFF'u8, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                    0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])

  # RFC 9562 predefined namespaces
  NamespaceDNS* = Uuid([0x6b'u8, 0xa7, 0xb8, 0x10, 0x9d, 0xad, 0x11, 0xd1,
                         0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8])

  NamespaceURL* = Uuid([0x6b'u8, 0xa7, 0xb8, 0x11, 0x9d, 0xad, 0x11, 0xd1,
                         0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8])

  NamespaceOID* = Uuid([0x6b'u8, 0xa7, 0xb8, 0x12, 0x9d, 0xad, 0x11, 0xd1,
                         0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8])

  NamespaceX500* = Uuid([0x6b'u8, 0xa7, 0xb8, 0x14, 0x9d, 0xad, 0x11, 0xd1,
                          0x80, 0xb4, 0x00, 0xc0, 0x4f, 0xd4, 0x30, 0xc8])

proc bytes*(u: Uuid): array[16, byte] {.inline.} =
  array[16, byte](u)

proc toUuid*(b: array[16, byte]): Uuid {.inline.} =
  Uuid(b)

proc version*(u: Uuid): UuidVersion =
  let v = int(array[16, byte](u)[6] shr 4)
  if v >= ord(uvNone) and v <= ord(uvV8):
    UuidVersion(v)
  else:
    uvNone

proc variant*(u: Uuid): UuidVariant =
  let b = array[16, byte](u)[8]
  if (b and 0x80) == 0:
    uvNCS
  elif (b and 0xC0) == 0x80:
    uvRFC9562
  elif (b and 0xE0) == 0xC0:
    uvMicrosoft
  else:
    uvFuture

proc isNil*(u: Uuid): bool =
  array[16, byte](u) == array[16, byte](NilUuid)

proc isMax*(u: Uuid): bool =
  array[16, byte](u) == array[16, byte](MaxUuid)

proc `==`*(a, b: Uuid): bool {.inline.} =
  array[16, byte](a) == array[16, byte](b)

proc `<`*(a, b: Uuid): bool =
  let aa = array[16, byte](a)
  let bb = array[16, byte](b)
  for i in 0 ..< 16:
    if aa[i] < bb[i]: return true
    if aa[i] > bb[i]: return false
  false

proc `<=`*(a, b: Uuid): bool {.inline.} =
  not (b < a)

proc `>`*(a, b: Uuid): bool {.inline.} =
  b < a

proc `>=`*(a, b: Uuid): bool {.inline.} =
  not (a < b)

proc cmp*(a, b: Uuid): int =
  let aa = array[16, byte](a)
  let bb = array[16, byte](b)
  for i in 0 ..< 16:
    if aa[i] < bb[i]: return -1
    if aa[i] > bb[i]: return 1
  0

proc hash*(u: Uuid): Hash {.inline.} =
  hash(array[16, byte](u))

proc toUuid*(n: uint64): Uuid =
  ## Creates a Uuid from a uint64 (stored in lower 8 bytes, big-endian).
  ## Upper 8 bytes are zero. No version/variant bits are set.
  ## Analogous to Python's UUID(int=N).
  var data: array[16, byte]
  data[8] = byte(n shr 56)
  data[9] = byte(n shr 48)
  data[10] = byte(n shr 40)
  data[11] = byte(n shr 32)
  data[12] = byte(n shr 24)
  data[13] = byte(n shr 16)
  data[14] = byte(n shr 8)
  data[15] = byte(n)
  Uuid(data)

proc toUuid*(n: int): Uuid =
  ## Creates a Uuid from an int (stored in lower 8 bytes, big-endian).
  ## Upper 8 bytes are zero. No version/variant bits are set.
  ## Raises RangeDefect if n is negative.
  if n < 0:
    raise newException(RangeDefect, "Cannot create UUID from negative integer")
  toUuid(uint64(n))

proc toUuid*(hi, lo: uint64): Uuid =
  ## Creates a Uuid from two uint64 values (full 128 bits, big-endian).
  ## No version/variant bits are set.
  var data: array[16, byte]
  data[0] = byte(hi shr 56)
  data[1] = byte(hi shr 48)
  data[2] = byte(hi shr 40)
  data[3] = byte(hi shr 32)
  data[4] = byte(hi shr 24)
  data[5] = byte(hi shr 16)
  data[6] = byte(hi shr 8)
  data[7] = byte(hi)
  data[8] = byte(lo shr 56)
  data[9] = byte(lo shr 48)
  data[10] = byte(lo shr 40)
  data[11] = byte(lo shr 32)
  data[12] = byte(lo shr 24)
  data[13] = byte(lo shr 16)
  data[14] = byte(lo shr 8)
  data[15] = byte(lo)
  Uuid(data)

proc hi*(u: Uuid): uint64 {.inline.} =
  ## Returns the upper 64 bits of the UUID.
  let data = array[16, byte](u)
  (uint64(data[0]) shl 56) or (uint64(data[1]) shl 48) or
  (uint64(data[2]) shl 40) or (uint64(data[3]) shl 32) or
  (uint64(data[4]) shl 24) or (uint64(data[5]) shl 16) or
  (uint64(data[6]) shl 8) or uint64(data[7])

proc lo*(u: Uuid): uint64 {.inline.} =
  ## Returns the lower 64 bits of the UUID.
  let data = array[16, byte](u)
  (uint64(data[8]) shl 56) or (uint64(data[9]) shl 48) or
  (uint64(data[10]) shl 40) or (uint64(data[11]) shl 32) or
  (uint64(data[12]) shl 24) or (uint64(data[13]) shl 16) or
  (uint64(data[14]) shl 8) or uint64(data[15])

proc setVersionAndVariant*(u: var Uuid, ver: uint8) =
  var data = array[16, byte](u)
  data[6] = (data[6] and 0x0F) or (ver shl 4)
  data[8] = (data[8] and 0x3F) or 0x80
  u = Uuid(data)
