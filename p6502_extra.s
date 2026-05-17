.segment "EXTRA"
.export MONCOUT, MONRDKEY, LOAD, SAVE

MMIO_OP := $FFE0
MMIO_SPIN := $FFE1
MMIO_A := $FFE4
MMIO_UART_TX := $FFEF

OP_PUTCHAR := $8
OP_GETCHAR := $9

; Modifies flags, A, X
MONCOUT:
    pha
    phx

    ;sta MMIO_UART_TX
    ;lda     #$FF
@txdelay:
    ;dec
    ;bne     @txdelay

    sta MMIO_A
    lda #OP_PUTCHAR
    sta MMIO_OP
    jsr MMIO_SPIN   ; modifies A & X

    plx
    pla
    rts

; Modifies flags, A, X
MONRDKEY:
    phx

    lda #OP_GETCHAR
    sta MMIO_OP
    jsr MMIO_SPIN   ; modifies A & X

    jsr MONCOUT     ; echo
    
    plx
    rts

LOAD:
    rts

SAVE:
    rts
