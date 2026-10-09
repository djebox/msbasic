.segment "CODE"

LS_ERR_BADDATA:
        ldx #ERR_OVERFLOW
        jmp ERROR

SAVE:
        jsr FRMEVL
        jsr CHKSTR
        jsr FREFAC

        tay                                     ; length -> y
        beq LS_ERR_BADDATA                      ; if y == 0

@push_loop:
        dey
        lda (INDEX), y
        sta MMIO_XSTACK
        tya
        bne @push_loop

        lda #<O_WRONLY | O_CREAT | O_TRUNC      ; LSB
        sta MMIO_A

        ldx #>O_WRONLY | O_CREAT | O_TRUNC      ; MSB
        stx MMIO_X
    
        ; open
        lda #OP_OPEN
        sta MMIO_OP
        jsr MMIO_SPIN

        sta FILDES

        ; write
        ;lda #0
        ;sta COUNT
        jsr WRITE_PROG

        ; flush
        ;jsr FLUSH

        ; close
        lda FILDES
        sta MMIO_A

        lda #OP_CLOSE
        sta MMIO_OP
        jsr MMIO_SPIN

        rts

WRITE_PROG:
        lda TXTTAB
        sta LIGPTR                              ; zp
        lda TXTTAB + 1
        sta LIGPTR + 1

WRITE_LINE:
        ; 0-1: next line pointer
        ; 2-3: line number
        ; 4+: BASIC tokens 

        ldy #0

        lda (LIGPTR), y
        sta NXTLIG
        iny

        lda (LIGPTR), y
        sta NXTLIG + 1
        iny

        lda NXTLIG
        ora NXTLIG + 1
        beq WRITE_END

        ; line number low
        lda (LIGPTR), y
        jsr WRITE_BYTE
        iny

        ; line number high
        lda (LIGPTR), y
        jsr WRITE_BYTE
        iny

WRITE_CHAR:
        lda (LIGPTR), y

        cmp #$80
        bcs @token                              ; >= 0x80

        cmp #0
        beq @eol

        jsr WRITE_BYTE
        iny

        jmp WRITE_CHAR

@token:
        jsr WRITE_TOKEN
        iny

        jmp WRITE_CHAR

@eol:
        lda #$0d
        jsr WRITE_BYTE
        lda #$0a
        jsr WRITE_BYTE

        jmp WRITE_NEXT_LINE

WRITE_TOKEN:
        sec
        sbc #$80
        tax

        lda #<TOKEN_NAME_TABLE
        sta TOKPTR                              ; zp
        lda #>TOKEN_NAME_TABLE
        sta TOKPTR + 1

@check_token:
        cpx #0
        beq @write_token

@skip_token:
        lda (TOKPTR)
        inc TOKPTR
        bne :+                                  ; next anonym label
        inc TOKPTR + 1
:                                               ; anonym label
        and #$80
        beq @skip_token

        dex
        jmp @check_token

@write_token:
        lda (TOKPTR)

        pha
        and #$7f                                ; retirer le bit de terminaison
        jsr WRITE_BYTE
        pla
        bmi @end_token                          ; bit 7 était positionné

        inc TOKPTR
        bne @write_token
        inc TOKPTR + 1
        jmp @write_token

@end_token:
        rts

WRITE_NEXT_LINE:
        lda NXTLIG
        sta LIGPTR
        lda NXTLIG + 1
        sta LIGPTR + 1

        jmp WRITE_LINE

WRITE_END:
        rts

WRITE_BYTE:
        sta MMIO_XSTACK

        ;inc COUNT
        ;bne @done                               ; $ff -> 0

        ;jsr FLUSH

@done:
        ;rts

FLUSH:
        lda FILDES
        sta MMIO_A
        
        lda #OP_WRITE
        sta MMIO_OP
        jsr MMIO_SPIN

        ;lda #0
        ;sta COUNT
        
        rts

LOAD:
        rts

FILDES:
        .res 2
NXTLIG:
        .res 2
COUNT:
        .res 1