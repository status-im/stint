# Stint
# Copyright 2018 Status Research & Development GmbH
# Licensed under either of
#
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
#  * MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)
#
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ./private/datatypes,
  ./private/int_negabs,
  typetraits

func stuint*[T: SomeInteger](n: T, bits: static[int]): StUint[bits] {.inline.}=
  assert n >= 0.T
  when result.data is UintImpl:
    when getSize(n) > bits:
      # To avoid a costly runtime check, we refuse storing into StUint types smaller
      # than the input type.
      raise newException(ValueError, "Input " & $n & " (" & $T &
                                    ") cannot be stored in a multi-precision " &
                                    $bits & "-bit integer." &
                                    "\nUse a smaller input type instead. This is a compile-time check" &
                                    " to avoid a costly run-time bit_length check at each StUint initialization.")
    else:
      let r_ptr = cast[ptr array[bits div (sizeof(T) * 8), T]](result.addr)
      when system.cpuEndian == littleEndian:
        # "Least significant byte are at the beginning"
        r_ptr[0] = n
      else:
        r_ptr[r_ptr[].len - 1] = n
  else:
    result.data = (type result.data)(n)

func stint*[T: SomeInteger](n: T, bits: static[int]): StInt[bits] {.inline.}=

  when result.data is IntImpl:
    when getSize(n) > bits:
      # To avoid a costly runtime check, we refuse storing into StUint types smaller
      # than the input type.
      raise newException(ValueError, "Input " & $n & " (" & $T &
                                    ") cannot be stored in a multi-precision " &
                                    $bits & "-bit integer." &
                                    "\nUse a smaller input type instead. This is a compile-time check" &
                                    " to avoid a costly run-time bit_length check at each StUint initialization.")
    else:
      let r_ptr = cast[ptr array[bits div (sizeof(T) * 8), T]](result.addr)
      when system.cpuEndian == littleEndian:
        # "Least significant byte are at the beginning"
        if n < 0:
          r_ptr[0] = -n
          result = -result
        else:
          r_ptr[0] = n
      else:
        if n < 0:
          r_ptr[r_ptr[].len - 1] = -n
          result = -result
        else:
          r_ptr[r_ptr[].len - 1] = n
  else:
    result.data = (type result.data)(n)