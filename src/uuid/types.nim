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

proc setVersionAndVariant*(u: var Uuid, ver: uint8) =
  var data = array[16, byte](u)
  data[6] = (data[6] and 0x0F) or (ver shl 4)
  data[8] = (data[8] and 0x3F) or 0x80
  u = Uuid(data)
