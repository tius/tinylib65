;   print_mem.s
;
;   helper functions for printing
;
;   prerequisites:
;       - print_char (must preserve tmp6 and tmp7)
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
.include "tinylib65.inc"

.code
;==============================================================================
print_mem_row:
;------------------------------------------------------------------------------
;   input:
;       A       no. of bytes to print
;       w0      start address
;   output:
;       w0      end address + 1
;------------------------------------------------------------------------------
    pha
    lda #':'
    jsr print_char_space
    jsr print_hex16_w0
    pla

;==============================================================================
print_hex_bytes_crlf:
;------------------------------------------------------------------------------
;   print line with multiple hex values separated by space
;
;   input:
;       A       no. of values                   
;       w0      start address
;   output:
;       w0      end address + 1
;------------------------------------------------------------------------------
@loop:     
    pha
    jsr print_space
    lda (w0)
    jsr print_hex8
    jsr inc_w0
    pla

    dec
    bne @loop
    jmp print_crlf

;==============================================================================
