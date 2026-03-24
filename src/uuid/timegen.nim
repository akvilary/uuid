## Shared timestamp and clock sequence generation for UUID v1 and v6.

import std/[times, sysrand, locks]

const
  gregorianOffset* = 122_192_928_000_000_000'u64
    ## 100ns intervals from 1582-10-15 to 1970-01-01.

var
  lastTimestamp: uint64 = 0
  clockSeq: uint16 = 0
  nodeId: array[6, byte]
  initialized: bool = false
  stateLock: Lock

proc initState() =
  initLock(stateLock)
  var buf: array[8, byte]
  if not urandom(buf):
    raise newException(OSError, "Failed to generate random bytes")
  clockSeq = (uint16(buf[0]) shl 8 or uint16(buf[1])) and 0x3FFF
  for i in 0 ..< 6:
    nodeId[i] = buf[i + 2]
  nodeId[0] = nodeId[0] or 0x01  # multicast bit

proc getTimestampAndClockSeq*(): tuple[ts: uint64, clockSeq: uint16, node: array[6, byte]] =
  ## Returns (60-bit Gregorian timestamp, 14-bit clock_seq, 6-byte node).
  ## Thread-safe with clock regression handling.
  if not initialized:
    initState()
    initialized = true
  withLock(stateLock):
    let now = getTime()
    let ts = uint64(now.toUnix + 12_219_292_800'i64) * 10_000_000'u64 +
             uint64(now.nanosecond div 100)
    if ts <= lastTimestamp:
      clockSeq = (clockSeq + 1) and 0x3FFF
    lastTimestamp = ts
    result = (ts, clockSeq, nodeId)
