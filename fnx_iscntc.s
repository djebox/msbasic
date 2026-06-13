.segment "CODE"

ISCNTC:
    jsr MONRDKEY_NB
    bcc @no_data
    cmp #$03
    beq @is_ctnc
@no_data:
    rts
@is_ctnc:
    ; Fall throughs