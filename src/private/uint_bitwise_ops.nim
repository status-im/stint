# Mpint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import  ./uint_type, ./size_mpuintimpl, ./conversion


proc `not`*(x: MpUintImpl): MpUintImpl {.noInit, noSideEffect, inline.}=
  ## Bitwise complement of unsigned integer x
  result.lo = not x.lo
  result.hi = not x.hi

proc `or`*(x, y: MpUintImpl): MpUintImpl {.noInit, noSideEffect, inline.}=
  ## `Bitwise or` of numbers x and y
  result.lo = x.lo or y.lo
  result.hi = x.hi or y.hi

proc `and`*(x, y: MpUintImpl): MpUintImpl {.noInit, noSideEffect, inline.}=
  ## `Bitwise and` of numbers x and y
  result.lo = x.lo and y.lo
  result.hi = x.hi and y.hi

proc `xor`*(x, y: MpUintImpl): MpUintImpl {.noInit, noSideEffect, inline.}=
  ## `Bitwise xor` of numbers x and y
  result.lo = x.lo xor y.lo
  result.hi = x.hi xor y.hi

proc `shl`*(x: MpUintImpl, y: SomeInteger): MpUintImpl {.inline, noSideEffect.}=
  ## Compute the `shift left` operation of x and y
  # Note: inlining this poses codegen/aliasing issue when doing `x = x shl 1`
  const halfSize = size_mpuintimpl(x) div 2

  result.hi = (x.hi shl y) or (x.lo shl (y - halfSize))
  if y < halfSize:
    result.lo = x.lo shl y

proc `shr`*(x: MpUintImpl, y: SomeInteger): MpUintImpl {.inline, noSideEffect.}=
  ## Compute the `shift right` operation of x and y
  const halfSize = size_mpuintimpl(x) div 2

  let overflow = y < halfSize

  result.lo = (x.lo shr y) or (
    if overflow: x.hi shl (halfSize - y) else: x.hi shr (y - halfSize)
  )
  if overflow:
    result.hi = x.hi shr y