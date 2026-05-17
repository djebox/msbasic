.segment "EXTRA"
.export MONCOUT, MONRDKEY, LOAD, SAVE

MMIO_OP := $FFE0
MMIO_SPIN := $FFE1
MMIO_A := $FFE4
MMIO_UART_TX := $FFEF

OP_GETCHAR := $8

; Modifies flags
MONCOUT:
    sta MMIO_UART_TX
    rts

; Modifies flags, A, X
MONRDKEY:
    phx
    lda #OP_GETCHAR
    sta MMIO_OP
    jsr MMIO_SPIN   ; modifies A & X
    jsr MONCOUT
    plx
    rts

LOAD:
    rts

SAVE:
    rts
