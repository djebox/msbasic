.segment "CODE"

; must be non blocking
ISCNTC:
;    clc ; clear carry flag (convention for no error)
    sec ; set carry flag (convention for error)
    rts
