;   zp_utils.s
;
;   zero page locations used by the utility functions
;
;   see also:
;       - README.md
;
;------------------------------------------------------------------------------
;   MIT License
;
;   Copyright (c) 1978-2025 Matthias Waldorf, https://tius.org
;
;   Permission is hereby granted, free of charge, to any person obtaining a copy
;   of this software and associated documentation files (the "Software"), to deal
;   in the Software without restriction, including without limitation the rights
;   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;   copies of the Software, and to permit persons to whom the Software is
;   furnished to do so, subject to the following conditions:
;
;   The above copyright notice and this permission notice shall be included in all
;   copies or substantial portions of the Software.
;
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;   SOFTWARE.
;------------------------------------------------------------------------------

.include "config.inc"
.include "utils.inc"

.zeropage
;------------------------------------------------------------------------------
;   scratchpad
;   - caller saved
;   - may be overwritten by every function unless documented (!)
;   - may be shared across functions within the same module if documented
;   - may be used for parameters and return values if documented
;------------------------------------------------------------------------------
tmp:
tmp0:           .res 1                  
tmp1:           .res 1
tmp2:           .res 1
tmp3:           .res 1
tmp4:           .res 1
tmp5:           .res 1
tmp6:           .res 1
tmp7:           .res 1

;==============================================================================
;   zeropage registers
;   - callee saved
;   - may be used for parameters and return values if documented (deprecated)
;------------------------------------------------------------------------------
;   generic 8 bit values

r0:             .res 1
r1:             .res 1
r2:             .res 1
r3:             .res 1
r4:             .res 1
r5:             .res 1
r6:             .res 1
r7:             .res 1

;------------------------------------------------------------------------------
;   aliases for generic 16 bit values

w0              :=  r0
w0l             :=  r0
w0h             :=  r1
w1              :=  r2
w1l             :=  r2
w1h             :=  r3

;==============================================================================
;   return values
;------------------------------------------------------------------------------
last_error:     .res 1                  ; last error code
