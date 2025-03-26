#include <stdint.h>
#include "macros.h"
#include "registers.h"
#include "constants.h"
#include "modplay.h"
#include "iffl.h"
#include "irqload.h"
#include "dma.h"
#include "dmajobs.h"
#include "program.h"

extern void irq_main();

void program_mapcolourmem()
{
	__asm(  // MAP_MEMORY_IN1MB %0000, %1111
		" lda #0xff\n"
		" ldx #0b00000000\n"                // %0000
		" ldy #0xff\n"
		" ldz #0b00001111\n"
		" map"
	);

	// SAFE_COLOR_RAM       = 0xff80000 + 0x0800 = 0xff80800
	// SAFE_COLOR_RAM_IN1MB                      = 0x0080800
	// 80800 - $8000 = 0x78800
	// 0x78800 / 256 = 0x788    -> Y = 0x88, Z = 0x07

	__asm(  //	MAP_MEMORY $00000, %0000, SAFE_COLOR_RAM_IN1MB, %0001
		" lda #0x00\n"          // lda #<((offsetlower32kb) / 256)
		" ldx #0b00000000\n"    // ldx #>((offsetlower32kb) / 256) | (enablemasklower32kb << 4)
		" ldy #0x88\n"          // #<((offsetupper32kb - $8000) / 256)
		" ldz #0x17\n"          // #>((offsetupper32kb - $8000) / 256) | (enablemaskupper32kb << 4)
		" map\n"
		" eom\n"
	);
}

void program_unmapcolourmem()
{
	UNMAP_ALL
}
void program_loaddata()
{
	fl_init();
	fl_waiting();
	floppy_iffl_fast_load_init("DATA");
	floppy_iffl_fast_load(); // chars
	floppy_iffl_fast_load(); // pal
	floppy_iffl_fast_load(); // song
}

void program_init()
{
	VIC2.BORDERCOL = 0x00;
	VIC2.SCREENCOL = 0x00;
	modplay_init();
	modplay_initmod(ATTICADDRESS, SAMPLEADRESS);
	modplay_enable();

	dma_runjob((__far char *)&dma_clearcolorram1);
	dma_runjob((__far char *)&dma_clearcolorram2);
	//dma_runjob((__far char *)&dma_clearscreen1);
	//dma_runjob((__far char *)&dma_clearscreen2);
	dma_runjob((__far char *)&dma_copypalette);

	// render the first char for the background layer
	uint16_t i = GFXMEM / 64;
	for(uint16_t y=0; y<25; y++)
	{
		for(uint16_t x=0; x<SCREENWIDTH; x++)
		{
			poke(SCREEN + y*RRBSCREENWIDTH2 + 2*x + 0, (i >> 0) & 0xff);
			poke(SCREEN + y*RRBSCREENWIDTH2 + 2*x + 1, (i >> 8) & 0xff);
		}
	}

	// render the sprites
	for(uint16_t y=0; y<25; y++)
	{
		i = (GFXMEM / 64);
		for(uint16_t x=0; x<RRBWIDTH; x++)
		{
			lpoke(SAFE_COLOR_RAM + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 0, 0b00001100); // set to NCM mode and trim pixels
			lpoke(SAFE_COLOR_RAM + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 1, 0);
			poke(SCREEN          + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 0, ((i >> 0) & 0xff) + ((x>>1) & 0x0f) + 1);
			poke(SCREEN          + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 1, ((i >> 8) & 0xff));
		}
	}

	// render gotox chars and their positions
	for(uint16_t y=0; y<25; y++)
	{
		i = 0;
		for(uint16_t x=0; x<RRBWIDTH; x+=2)
		{
			lpoke(SAFE_COLOR_RAM + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 0, 0b10010000); // set gotox and transparency
			lpoke(SAFE_COLOR_RAM + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 1, 0); // pixel row mask flags
			poke(SCREEN          + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 0, (i >> 0) & 0xff);
			poke(SCREEN          + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 2*x + 1, (i >> 8) & 0xff);
			i += 4;
		}
	}

	// set last gotox to 320
	for(uint16_t y=0; y<25; y++)
	{
		poke(SCREEN + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 4*(RRBSPRITES-1) + 0, (320 >> 0) & 0xff);
		poke(SCREEN + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 4*(RRBSPRITES-1) + 1, (320 >> 8) & 0xff);
	}
}

uint8_t offset = 0;

void program_update()
{
	//program_mapcolourmem();

	for(uint16_t y=0; y<20; y++)
	{
		uint16_t i = 0;
		uint16_t pos1 = SCREEN + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 0;
		uint16_t pos2 = SCREEN + SCREENWIDTH2 + y*RRBSCREENWIDTH2 + 1;
		for(uint16_t x=0; x<RRBSPRITES-1; x++)
		{
			uint16_t sin = peek(&sine+64+i);
			poke(pos1 + 4*x, (sin+32) & 0xff);
			poke(pos2 + 4*x, (sin+32) >> 8);
			i++;
		}
	}

	// offset++;

	//program_unmapcolourmem();
}