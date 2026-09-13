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
        lda (INDEX),y
        sta MMIO_XSTACK
        tya
        bne @push_loop

        lda #<O_WRONLY | O_CREAT | O_TRUNC      ; LSB
        sta MMIO_A

        ldx #>O_WRONLY | O_CREAT | O_TRUNC      ; MSB
        stx MMIO_X
    
        lda #OP_OPEN
        sta MMIO_OP
        jsr MMIO_SPIN

        sta FILDES

        jsr WRITE

        lda FILDES
        sta MMIO_A

        lda #OP_CLOSE
        sta MMIO_OP
        jsr MMIO_SPIN

        rts

WRITE:
        lda TXTTAB
        sta PRGPTR                              ; zp
        lda TXTTAB+1
        sta PRGPTR+1

DEBUG:
        ;lda (PRGPTR),y
        ;jsr WRITE_BYTE
        ;iny
        ;cpy #16
        ;bne DEBUG
        ;rts

WRITE_LOOP:
        ldy #0
        lda (PRGPTR),y
        sta LIGPTR

        ldy #1
        lda (PRGPTR),y
        sta LIGPTR+1

        lda LIGPTR
        ora LIGPTR+1
        beq WRITE_END

        ; 0-1: next line pointer
        ; 2-3: line number
        ; 4+: BASIC tokens 
        ldy #2

        ; line number low
        lda (PRGPTR),y
        jsr WRITE_BYTE
        iny

        ; line number high
        lda (PRGPTR),y
        jsr WRITE_BYTE
        iny

WRITE_LINE:
        lda (PRGPTR),y

        cmp #$80
        bcs @token                              ; >= 0x80

        cmp #0
        beq @eol

        jsr WRITE_BYTE
        iny
        jmp WRITE_LINE

@token:
        jsr WRITE_TOKEN
        iny
        jmp WRITE_LINE

@eol:
        lda #$0d
        jsr WRITE_BYTE
        lda #$0a
        jsr WRITE_BYTE
        jmp WRITE_NEXT_LINE

WRITE_TOKEN:
        sec
        sbc #$80
        tax     ; if we call write_byte below

        lda #<TOKEN_NAME_TABLE
        sta TOKPTR                              ; zp
        lda #>TOKEN_NAME_TABLE
        sta TOKPTR+1

        ;lda (TOKPTR)
        ;jsr WRITE_BYTE

        ;inc TOKPTR
        ;lda (TOKPTR)
        ;jsr WRITE_BYTE

        ;inc TOKPTR
        ;lda (TOKPTR)
        ;jsr WRITE_BYTE

        ;rts

@find:
        cpx #0
        beq @write

@skip:
        lda (TOKPTR)
        inc TOKPTR
        bne :+                                  ; next anonym label
        inc TOKPTR+1
:
        and #$80
        beq @skip

        dex
        jmp @find

@write:
        ; TOKENPTR = début du token

@char:
        lda (TOKPTR)

        pha
        and #$7f                        ; retirer le bit de terminaison
        jsr WRITE_BYTE
        pla
        bmi @done                       ; bit 7 était positionné

        inc TOKPTR
        bne @char
        inc TOKPTR+1
        jmp @char

@done:
        rts

WRITE_NEXT_LINE:
        lda LIGPTR
        sta PRGPTR
        lda LIGPTR+1
        sta PRGPTR+1
        jmp WRITE_LOOP

WRITE_END:
        rts

WRITE_BYTE:
        sta MMIO_XSTACK

        lda FILDES
        sta MMIO_A
        
        lda #OP_WRITE
        sta MMIO_OP
        jsr MMIO_SPIN
        
        rts

LOAD:
        rts

FILDES:
        .res 2
LIGPTR:
        .res 2