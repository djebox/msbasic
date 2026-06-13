; configuration
CONFIG_2A := 1

CONFIG_SCRTCH_ORDER := 2

; zero page
ZP_START1 = $00 ; needs 10
ZP_START2 = $0A ; needs 6+60 for inputbuffer
ZP_START3 = $70 ; needs 11
ZP_START4 = $7B

; extra/override ZP variables
USR				:= GORESTART

; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP		:= $FA
WIDTH			:= 40
WIDTH2			:= 30

RAMSTART2		:= $3000

