.segment "CODE"

lsav_err_baddata:
        lda #ERR_OVERFLOW
        jmp ERROR

SAVE:
        jsr FRMEVL
        jsr CHKSTR
        jsr FREFAC

        tay                         ; length -> y
        beq lsav_err_baddata        ; if y == 0

        lda #0
        sta MMIO_XSTACK

@push_loop:
        dey
        lda (INDEX),y
        sta MMIO_XSTACK
        tya
        bne @push_loop

        lda #O_WRONLY | O_CREAT
        sta MMIO_A
    
        lda #OP_OPEN
        sta MMIO_OP
        jsr MMIO_SPIN   ; modifies A & X

        sta fd

        ;JSR WRITE

        lda fd
        sta MMIO_A

        lda #OP_CLOSE
        sta MMIO_OP
        jsr MMIO_SPIN   ; modifies A & X


        rts

WRITE:
        ;LDA TXTTAB
        ;STA SRC
        ;LDA TXTTAB+1
        ;STA SRC+1

LOOP:
        ;LDY #0

        ;LDA (SRC),Y
        ;STA TMP
        ;INY
        ;LDA (SRC),Y
        ;STA TMP+1

        ;LDA TMP
        ;ORA TMP+1
        ;BEQ DONE

WRITE_LINE:

        ;LDA (SRC),Y

        ;JSR WRITE_BYTE
        
        ;CMP #0
        ;BNE WRITE_NEXT

        ; fin ligne → next line
        ;LDA TMP
        ;STA SRC
        ;LDA TMP+1
        ;STA SRC+1
        ;JMP LOOP

WRITE_NEXT:
        ;INY
        ;JMP WRITE_LINE

DONE:
        ;LDA #0
        ;JSR WRITE_BYTE
        ;LDA #0
        ;JSR WRITE_BYTE

        ;rts

WRITE_BYTE:
        STA MMIO_XSTACK
        
        lda #OP_WRITE
        sta MMIO_OP
        jsr MMIO_SPIN   ; modifies A & X

LOAD:
        rts

fd:
        .res 2

SRC:
        ;.res 2
TMP:
        ;.res 2