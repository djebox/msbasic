.segment "EXTRA"
.export MONCOUT, MONRDKEY, LOAD, SAVE

MMIO_OP := $FFE0
MMIO_SPIN := $FFE1
MMIO_A := $FFE4

OP_PUTCHAR := $8
OP_GETCHAR := $9

MONCOUT:
    pha
    phx

    sta MMIO_A

    lda #OP_PUTCHAR
    sta MMIO_OP
    jsr MMIO_SPIN   ; modifies A & X

    plx
    pla

    rts

MONRDKEY_NB:
    phx

    lda #OP_GETCHAR
    sta MMIO_OP
    jsr MMIO_SPIN   ; modifies A & X

    cpx #1
    bne @no_data

    plx
    sec ; set carry flag
    rts

@no_data:
    plx
    clc ; clear carry flag
    rts

MONRDKEY:

@read_char:
    jsr MONRDKEY_NB
    bcc @read_char

    jsr MONCOUT     ; echo

    rts

LOAD:
    rts

SAVE:
    rts
