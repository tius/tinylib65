;   sd/sd_test.s
;
;   test sd card access
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
.include "global.inc"
.include "tinylib65.inc"
;------------------------------------------------------------------------------
buffer = $2000

.code
;==============================================================================
sd_test:
;------------------------------------------------------------------------------
    ldx #STACK_INIT
    jsr sd_init
    bcc @error

    jsr input_hex
    X_PUSH_MEM32 tmp0   

    X_PUSH16 buffer
    jsr sd_read_sector
    bcc @error

    ;   dump sector
    X_PUSH16 buffer
    X_PUSH16 512
    jmp x_memdump

@error:
    lda last_error
    jsr print_hex8
    jmp mon_err

;==============================================================================
