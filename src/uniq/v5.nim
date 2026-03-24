## UUID version 5: name-based with SHA-1.

import checksums/sha1
import ./types

proc uuid5*(namespace: Uuid, name: string): Uuid =
  ## Generates a version 5 UUID from namespace and name using SHA-1.
  var ctx = newSha1State()
  let nsBytes = namespace.bytes
  var nsChars: array[16, char]
  for i in 0 ..< 16:
    nsChars[i] = char(nsBytes[i])
  update(ctx, nsChars)
  update(ctx, name)
  let digest = finalize(ctx)
  var data: array[16, byte]
  for i in 0 ..< 16:
    data[i] = byte(digest[i])
  result = Uuid(data)
  setVersionAndVariant(result, 5)
