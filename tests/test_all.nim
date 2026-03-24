import std/[unittest, sets, hashes, os, times]
import uuid

suite "types":
  test "Uuid is 16 bytes":
    check sizeof(Uuid) == 16

  test "NilUuid":
    check NilUuid.isNil
    check not NilUuid.isMax
    check NilUuid.version == uvNone
    check $NilUuid == "00000000-0000-0000-0000-000000000000"

  test "MaxUuid":
    check MaxUuid.isMax
    check not MaxUuid.isNil
    check $MaxUuid == "ffffffff-ffff-ffff-ffff-ffffffffffff"

  test "namespace constants":
    check $NamespaceDNS == "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
    check $NamespaceURL == "6ba7b811-9dad-11d1-80b4-00c04fd430c8"
    check $NamespaceOID == "6ba7b812-9dad-11d1-80b4-00c04fd430c8"
    check $NamespaceX500 == "6ba7b814-9dad-11d1-80b4-00c04fd430c8"

  test "comparison":
    check NilUuid < MaxUuid
    check NilUuid <= MaxUuid
    check MaxUuid > NilUuid
    check MaxUuid >= NilUuid
    check NilUuid == NilUuid
    check cmp(NilUuid, MaxUuid) == -1
    check cmp(MaxUuid, NilUuid) == 1
    check cmp(NilUuid, NilUuid) == 0

  test "hash works for sets":
    var s: HashSet[Uuid]
    s.incl(NilUuid)
    s.incl(MaxUuid)
    s.incl(NilUuid)
    check s.len == 2

  test "bytes round-trip":
    let b = NamespaceDNS.bytes
    check toUuid(b) == NamespaceDNS

suite "from integer":
  test "toUuid from int":
    let u = toUuid(1)
    check $u == "00000000-0000-0000-0000-000000000001"

  test "toUuid from uint64":
    let u = toUuid(255'u64)
    check $u == "00000000-0000-0000-0000-0000000000ff"

  test "toUuid from zero":
    check toUuid(0) == NilUuid

  test "toUuid(hi, lo)":
    let u = toUuid(1'u64, 0'u64)
    check $u == "00000000-0000-0001-0000-000000000000"

  test "hi/lo round-trip":
    let u = toUuid(0xDEADBEEF'u64)
    check u.lo == 0xDEADBEEF'u64
    check u.hi == 0'u64

  test "hi/lo full 128-bit round-trip":
    let u = toUuid(0x1234567890ABCDEF'u64, 0xFEDCBA0987654321'u64)
    check u.hi == 0x1234567890ABCDEF'u64
    check u.lo == 0xFEDCBA0987654321'u64

  test "no version/variant bits set":
    let u = toUuid(1)
    check u.version == uvNone
    check u.variant == uvNCS

  test "negative int raises":
    expect RangeDefect:
      discard toUuid(-1)

suite "parse":
  test "round-trip":
    let s = "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
    let u = parseUuid(s)
    check $u == s

  test "case insensitive":
    let upper = parseUuid("6BA7B810-9DAD-11D1-80B4-00C04FD430C8")
    check upper == NamespaceDNS

  test "tryParseUuid valid":
    var u: Uuid
    check tryParseUuid("6ba7b810-9dad-11d1-80b4-00c04fd430c8", u)
    check u == NamespaceDNS

  test "tryParseUuid invalid":
    var u: Uuid
    check not tryParseUuid("not-a-uuid", u)
    check not tryParseUuid("6ba7b810-9dad-11d1-80b4-00c04fd430c", u)  # too short
    check not tryParseUuid("6ba7b810X9dad-11d1-80b4-00c04fd430c8", u)  # wrong dash
    check not tryParseUuid("6ba7b810-9dad-11d1-80b4-00c04fd430g8", u)  # invalid hex

  test "parseUuid raises on invalid":
    expect ValueError:
      discard parseUuid("garbage")

suite "v4 (random)":
  test "version and variant":
    let u = uuid4()
    check u.version == uvV4
    check u.variant == uvRFC9562

  test "not nil":
    let u = uuid4()
    check not u.isNil

  test "uniqueness":
    var s: HashSet[Uuid]
    for i in 0 ..< 10000:
      s.incl(uuid4())
    check s.len == 10000

suite "v3 (MD5)":
  test "RFC 9562 test vector":
    let u = uuid3(NamespaceDNS, "www.example.com")
    check $u == "5df41881-3aed-3515-88a7-2f4a814cf09e"

  test "version and variant":
    let u = uuid3(NamespaceDNS, "test")
    check u.version == uvV3
    check u.variant == uvRFC9562

  test "deterministic":
    let a = uuid3(NamespaceURL, "https://example.com")
    let b = uuid3(NamespaceURL, "https://example.com")
    check a == b

  test "different names produce different UUIDs":
    let a = uuid3(NamespaceDNS, "foo")
    let b = uuid3(NamespaceDNS, "bar")
    check a != b

suite "v5 (SHA-1)":
  test "RFC 9562 test vector":
    let u = uuid5(NamespaceDNS, "www.example.com")
    check $u == "2ed6657d-e927-568b-95e1-2665a8aea6a2"

  test "version and variant":
    let u = uuid5(NamespaceDNS, "test")
    check u.version == uvV5
    check u.variant == uvRFC9562

  test "deterministic":
    let a = uuid5(NamespaceOID, "1.2.3.4")
    let b = uuid5(NamespaceOID, "1.2.3.4")
    check a == b

suite "v1 (time-based)":
  test "version and variant":
    let u = uuid1()
    check u.version == uvV1
    check u.variant == uvRFC9562

  test "node multicast bit":
    let data = uuid1().bytes
    check (data[10] and 0x01) == 0x01

  test "sequential generation":
    let a = uuid1()
    let b = uuid1()
    check a != b

suite "v6 (reordered time-based)":
  test "version and variant":
    let u = uuid6()
    check u.version == uvV6
    check u.variant == uvRFC9562

  test "sortable ordering":
    let a = uuid6()
    sleep(1)
    let b = uuid6()
    check a < b

  test "node multicast bit":
    let data = uuid6().bytes
    check (data[10] and 0x01) == 0x01

suite "v7 (Unix epoch time-based)":
  test "version and variant":
    let u = uuid7()
    check u.version == uvV7
    check u.variant == uvRFC9562

  test "sortable ordering":
    let a = uuid7()
    sleep(2)
    let b = uuid7()
    check a < b

  test "timestamp is recent":
    let u = uuid7()
    let data = u.bytes
    let ms = (uint64(data[0]) shl 40) or (uint64(data[1]) shl 32) or
             (uint64(data[2]) shl 24) or (uint64(data[3]) shl 16) or
             (uint64(data[4]) shl 8) or uint64(data[5])
    let nowMs = uint64(epochTime() * 1000)
    check ms > nowMs - 5000  # within 5 seconds
    check ms <= nowMs + 1000

suite "v8 (custom)":
  test "version and variant from bytes":
    var data: array[16, byte]
    for i in 0 ..< 16:
      data[i] = byte(i)
    let u = uuid8(data)
    check u.version == uvV8
    check u.variant == uvRFC9562

  test "version and variant from uint64":
    let u = uuid8(0xDEADBEEF_CAFEBABE'u64, 0x12345678_9ABCDEF0'u64)
    check u.version == uvV8
    check u.variant == uvRFC9562

  test "custom bits preserved (except version/variant)":
    var data: array[16, byte]
    for i in 0 ..< 16:
      data[i] = 0xFF
    let u = uuid8(data)
    let b = u.bytes
    # byte 6 upper nibble = version 8
    check (b[6] shr 4) == 8
    # byte 6 lower nibble preserved
    check (b[6] and 0x0F) == 0x0F
    # byte 8 upper 2 bits = variant 10
    check (b[8] and 0xC0) == 0x80
    # byte 8 lower 6 bits preserved
    check (b[8] and 0x3F) == 0x3F
    # other bytes untouched
    check b[0] == 0xFF
    check b[15] == 0xFF
