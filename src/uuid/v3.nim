## UUID version 3: name-based with MD5.

import checksums/md5
import ./types

proc uuid3*(namespace: Uuid, name: string): Uuid =
  ## Generates a version 3 UUID from namespace and name using MD5.
  var ctx: MD5Context
  md5Init(ctx)
  let nsBytes = namespace.bytes
  var nsBuf: array[16, uint8]
  for i in 0 ..< 16:
    nsBuf[i] = uint8(nsBytes[i])
  md5Update(ctx, nsBuf)
  var nameBuf = newSeq[uint8](name.len)
  for i in 0 ..< name.len:
    nameBuf[i] = uint8(name[i])
  md5Update(ctx, nameBuf)
  var digest: MD5Digest
  md5Final(ctx, digest)
  var data: array[16, byte]
  for i in 0 ..< 16:
    data[i] = byte(digest[i])
  result = Uuid(data)
  setVersionAndVariant(result, 3)
