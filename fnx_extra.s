.segment "EXTRA"
.export MONCOUT, MONRDKEY

MMIO_XSTACK := $FFEA
MMIO_SPIN := $FFF0
MMIO_A := $FFF3
MMIO_OP := $FFF9

OP_PUTCHAR := $8
OP_GETCHAR := $9
OP_OPEN := $a
OP_WRITE := $b
OP_CLOSE := $c

O_WRONLY := $1
O_CREAT := $40
O_TRUNC := $200

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
