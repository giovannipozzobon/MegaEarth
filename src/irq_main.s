			.rtmodel cpu, "*"

			.extern _Zp

			.extern modplay_play
			.extern program_update

			.extern sine

SCREEN			.equ 0x5000

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

			lda #0x01
			sta 0xd021

			lda #0x02
			sta 0xd020

			jsr program_update

			lda #0x04
			sta 0xd020

			jsr docopystuff

			lda #0x06
			sta 0xd020

			jsr modplay_play

			lda #0x01
			sta 0xd020

			lda #.byte0 (SCREEN + 0*RRBSCREENWIDTH2)
			sta 0xd060
			lda #.byte1 (SCREEN + 0*RRBSCREENWIDTH2)
			sta 0xd061

			lda #.byte0 (SCREEN + 1*RRBSCREENWIDTH2)
			sta scrptrlo+1
			lda #.byte1 (SCREEN + 1*RRBSCREENWIDTH2)
			sta scrptrhi+1

			lda #0x68						; reset textypos for start of screen
			sta 0xd04e
			lda #0x00
			sta 0xd04f

			lda #0x69+4
			sta textyposlo+1
			lda #0x00
			sta textyposhi+1

			lda #0x35
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

			lda #0x07
			sta 0xd020

scrptrlo:	lda #.byte0 (SCREEN + 1*RRBSCREENWIDTH2)
			sta 0xd060
scrptrhi:	lda #.byte1 (SCREEN + 1*RRBSCREENWIDTH2)
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

			lda #0x01
			sta 0xd020

			clc
			lda raster+1
			adc #4
			sta raster+1
			cmp #0x35+50*4
			beq endloop

			;jmp endloop

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

copyline

		; load up c64run at $4,2000
		sta 0xd707							; inline DMA copy
		.byte 0x80, 0						; sourcemb
		.byte 0x81, 0						; destmb
		.byte 0x85, 4						; dst skip rate
		.byte 0x00							; end of job options

		.byte 0x00							; copy, no chain
		.word 127							; count 128-1 because I don't want to touch the last gotox320 bytes
cpsrc:	.word sine							; src (fill value)
		.byte 0x00							; src bank (ignored)
cpdst:	.word SCREEN+SCREENWIDTH			; dst
		.byte 0x00							; dst bank
		.byte 0x00							; cmd hi
		.word 0x0000						; modulo, ignored

		rts

; ------------------------------------------------------------------------------------

frame	.byte 0

docopystuff

		inc frame

		ldx #0

		lda frame
		sta cpsrc+0

		lda #.byte0 (SCREEN+SCREENWIDTH2)
		sta cpdst+0
		lda #.byte1 (SCREEN+SCREENWIDTH2)
		sta cpdst+1

copylineloop:
		jsr copyline

		clc
		lda cpdst+0
		adc #.byte0 RRBSCREENWIDTH2
		sta cpdst+0
		lda cpdst+1
		adc #.byte1 RRBSCREENWIDTH2
		sta cpdst+1

		inc cpsrc+0

		inx
		cpx #50
		bne copylineloop

		rts

; ------------------------------------------------------------------------------------
