;   serial_tx.s
;
;   bit-bang 57600 baud software serial output
;
;   config:
;       SERIAL_TX_PORT             output register
;       SERIAL_TX_PORT_PIN         output pin number (0 for fastest code)
;       SERIAL_TX_PORT_IDLE        output register default state
;       SERIAL_TX_PORT_PRESERVE    preserve output port state
;
;   requirements:
;       - data direction register set to output for SERIAL_TX_BIT
;       - output register initialized for output high
;
;   caveat:
;       - tmp6 and tmp7 are reserved for the caller and must be preserved (!)
;
;   remarks:
;       - half-duplex only
;       - correct bit time is 17.36 cycles, tight timing is required
;       - simplified timing 19/17/17/17/17/17/17/17/18 is precise enough for tx
;       - maximum waveform timing error is 1.64 cycles
;       - branches must not cross pages for correct timing 
;       - using bit 0 allows faster and smaller code
;       - not keeping port output state allows further optimization
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

.ifdef SERIAL_TX_PORT

.code
;==============================================================================
serial_tx_byte:
;==============================================================================

.if SERIAL_TX_PORT_SAVE
;##############################################################################
;   preserve output port state
;
;   caveats:
;       - reading SERIAL_TX_PORT actually reads the input port on 65x22
;       - this may not always reflect the actual output state
;##############################################################################

.if SERIAL_TX_PORT_PIN = 0
;==============================================================================
.out "using optimized serial_tx_byte for bit 0"
;------------------------------------------------------------------------------
;   in:
;       A       byte to transmit
;------------------------------------------------------------------------------
    sta tmp0                            ; 3
    lda SERIAL_TX_PORT                 ; 4
    and #$FE                            ; 2     
    sta SERIAL_TX_PORT                 ; 4     start bit
    sec                                 ; 2     end of byte marker
    ror tmp0                            ; 5     tmp0 = $80, c = 0
    DELAY6                              ; 6     
                                        ; 26    

    ;   repeat 8 times          
@l0:        
    adc #$00                            ; 2
    sta SERIAL_TX_PORT                 ; 4     
    and #$FE                            ; 2
    lsr a:tmp0                          ; 6     use absolute addressing (!)
    ASSERT_BRANCH_PAGE bne, @l0         ; 3/2   zero after last data bit
                                        ; 17    total 135 = 17 * 8 - 1

    ora #$01                            ; 2
    nop                                 ; 2
    sta SERIAL_TX_PORT                 ; 4     
    rts                                 ; 6
                                        ; 14
;   total 175 = 26 + 135 + 14                                                

.else
;==============================================================================
.out "using default serial_tx_byte"
;------------------------------------------------------------------------------
;   in:
;       A       byte to transmit
;------------------------------------------------------------------------------
    phy                                 ; 3
    phx                                 ; 3

    ;   load x and y with bit masks for hi and lo output
    pha                                 ; 3
    lda SERIAL_TX_PORT                 ; 4
    ora #1 << SERIAL_TX_BIT            ; 2
    tax                                 ; 2
    and #$FF ^ (1 << SERIAL_TX_BIT)    ; 2
    tay                                 ; 2
    pla                                 ; 4

    sty SERIAL_TX_PORT                 ; 4     start bit
    sec                                 ; 2     end of byte marker
    ror                                 ; 2
    DELAY6                              ; 6 
                                        ; 39    total

;   repeat 8 times  
@l0:	    
    bcc @l1		                        ; 3/2 	
    DELAY3                              ; 3
    stx	SERIAL_TX_PORT                 ; 4
    bcs @l2		                        ; 3
@l1:		                    
    DELAY2                              ; 2
    sty SERIAL_TX_PORT                 ; 4			
    DELAY3                              ; 3
@l2:		                    
    lsr			                        ; 2
    ASSERT_BRANCH_PAGE bne, @l0		    ; 3/2
                                        ; 17    total 135 = 17 * 8 - 1

    DELAY7                              ; 7
    stx SERIAL_TX_PORT                 ; 4     stop bit
    plx                                 ; 4
    ply                                 ; 4
    rts                                 ; 6
                                        ; 25
;   total 199 = 39 + 135 + 25

.endif
;==============================================================================

.else
;##############################################################################
;   do NOT preserve output port state
;
;   caveat:
;       - resets output port to SERIAL_TX_PORT_IDLE after each byte    
;##############################################################################
_OUT_LO := SERIAL_TX_PORT_IDLE ^ (1 << SERIAL_TX_PORT_PIN) 
_OUT_HI := SERIAL_TX_PORT_IDLE | (1 << SERIAL_TX_PORT_PIN)

.if SERIAL_TX_PORT_PIN = 0
;==============================================================================
.out "using optimized serial_tx_byte for bit 0, trashing output port state"
;------------------------------------------------------------------------------
;   in:
;       A       byte to transmit
;------------------------------------------------------------------------------
    sta tmp0                            ; 3
    lda #_OUT_LO                        ; 2
    sta SERIAL_TX_PORT                 ; 4     start bit
    sec                                 ; 2     end of byte marker
    ror tmp0                            ; 5     tmp0 = $80, c = 0
    DELAY6                              ; 6     
                                        ; 22    

    ;   repeat 8 times          
@l0:        
    adc #$00                            ; 2
    sta SERIAL_TX_PORT                 ; 4     
    lda #_OUT_LO                        ; 2
    lsr a:tmp0                          ; 6     use absolute addressing (!)
    ASSERT_BRANCH_PAGE bne, @l0         ; 3/2   zero after last data bit
                                        ; 17    total 135 = 17 * 8 - 1

    lda #_OUT_HI                        ; 2     stop bit
    nop                                 ; 2
    sta SERIAL_TX_PORT                 ; 4     
    rts                                 ; 6
                                        ; 14
;   total 171 = 22 + 135 + 14                                                

.else
;==============================================================================
.out "using default serial_tx_byte, trashing output port state"
;------------------------------------------------------------------------------
;   in:
;       A       byte to transmit
;------------------------------------------------------------------------------
    phx                                 ; 3

    ;   load x and y with bit masks for hi and lo output
    ldx #_OUT_LO                        ; 2
    stx SERIAL_TX_PORT                 ; 4     start bit
    sec                                 ; 2     end of byte marker
    ror                                 ; 2
    DELAY6                              ; 6 
                                        ; 19    total

;   repeat 8 times  
@l0:	    
    bcc @l1		                        ; 3/2 	
    DELAY1                              ; 1
    ldx #_OUT_HI                        ; 2
    stx	SERIAL_TX_PORT                 ; 4
    bcs @l2		                        ; 3
@l1:		                    
    ldx #_OUT_LO                        ; 2
    stx SERIAL_TX_PORT                 ; 4			
    DELAY3                              ; 3
@l2:		                    
    lsr			                        ; 2
    ASSERT_BRANCH_PAGE bne, @l0		    ; 3/2
                                        ; 17    total 135 = 17 * 8 - 1

    DELAY5                              ; 5
    ldx #_OUT_HI                        ; 2
    stx SERIAL_TX_PORT                 ; 4     stop bit

    plx                                 ; 4
    rts                                 ; 6
                                        ; 21
;   total 175 = 19 + 135 + 21

.endif
;==============================================================================



;##############################################################################
.endif
;##############################################################################
.endif
