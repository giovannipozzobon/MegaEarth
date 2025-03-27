			.rtmodel cpu, "*"

			.extern _Zp

			.extern modplay_play
			.extern program_update

SCREENWIDTH		.equ 20
RRBSPRITES		.equ 128
RRBWIDTH		.equ (2*RRBSPRITES)
RRBSCREENWIDTH	.equ (SCREENWIDTH+RRBWIDTH)

SCREENWIDTH2	.equ (2*SCREENWIDTH)
RRBSCREENWIDTH2	.equ (2*RRBSCREENWIDTH)
RRBWIDTH2		.equ (2*RRBWIDTH)

 ; ------------------------------------------------------------------------------------

			.public irq_main
irq_main:
			php
			pha
			phx
			phy
			phz

			lda #0x02
			sta 0xd020

			jsr program_update

			lda #0x04
			sta 0xd020

			jsr modplay_play

			lda #0x06
			sta 0xd020

			lda #0x01
			sta 0xd021

			lda #.byte0 (0x8000 + 0*RRBSCREENWIDTH2)
			sta 0xd060
			lda #.byte1 (0x8000 + 0*RRBSCREENWIDTH2)
			sta 0xd061

			lda #.byte0 (0x8000 + 1*RRBSCREENWIDTH2)
			sta scrptrlo+1
			lda #.byte1 (0x8000 + 1*RRBSCREENWIDTH2)
			sta scrptrhi+1

			lda #0x68						; reset textypos for start of screen
			sta 0xd04e
			lda #0x00
			sta 0xd04f

			lda #0x69+4
			sta textyposlo+1
			lda #0x00
			sta textyposhi+1

			lda #0x33+2
			sta 0xd012
			sta raster+1

			lda #.byte0 irq_main2
			sta 0xfffe
			lda #.byte1 irq_main2
			sta 0xffff

			plz
			ply
			plx
			pla
			plp
			asl 0xd019
			rti

; ------------------------------------------------------------------------------------

irq_main2:
			php
			pha
			phx
			phy
			phz

			inc 0xd020

scrptrlo:	lda #.byte0 (0x8000 + 1*RRBSCREENWIDTH2)
			sta 0xd060
scrptrhi:	lda #.byte1 (0x8000 + 1*RRBSCREENWIDTH2)
			sta 0xd061

textyposlo:	lda #0x67
			sta 0xd04e
textyposhi:	lda #0x00
			sta 0xd04f

			clc
			lda scrptrlo+1
			adc #.byte0 RRBSCREENWIDTH2
			sta scrptrlo+1
			lda scrptrhi+1
			adc #.byte1 RRBSCREENWIDTH2
			sta scrptrhi+1

			clc
			lda textyposlo+1
			adc #8
			sta textyposlo+1
			lda textyposhi+1
			adc #0x00
			sta textyposhi+1

			clc
			lda raster+1
			adc #4
			sta raster+1
			cmp #0x35+25*4
			beq endloop

raster:		lda #0x34
			sta 0xd012

			plz
			ply
			plx
			pla
			plp
			asl 0xd019
			rti

endloop:

			lda #0xff
			sta 0xd012

			lda #.byte0 irq_main
			sta 0xfffe
			lda #.byte1 irq_main
			sta 0xffff

			plz
			ply
			plx
			pla
			plp
			asl 0xd019
			rti

; ------------------------------------------------------------------------------------
