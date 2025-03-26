#ifndef __CONSTANTS_H
#define __CONSTANTS_H

#define SCREEN					0x8000

// theoretical maximum number of sprites:
// $2000/25 = 327

// 327 - 40 = 287
// 287/4 = 71 sprites

//327/2 = 163 RRBSCREENWIDTH

#define SCREENWIDTH             20
#define RRBSPRITES              128
#define RRBWIDTH				(2*RRBSPRITES)
#define RRBSCREENWIDTH			(SCREENWIDTH+RRBWIDTH)

// mem = 2*(20+(2*128))
// 25 * 552 = $35e8

#define SCREENWIDTH2            (2*SCREENWIDTH)
#define RRBSCREENWIDTH2			(2*RRBSCREENWIDTH)
#define RRBWIDTH2               (2*RRBWIDTH)

#define PALETTE					0xc000

#define GFXMEM					0x10000

#define COLOR_RAM				0xff80000
#define COLOR_RAM_OFFSET		0x0800
#define SAFE_COLOR_RAM			(COLOR_RAM + COLOR_RAM_OFFSET)
#define SAFE_COLOR_RAM_IN1MB	(SAFE_COLOR_RAM - $ff00000)	

#define MAPPEDCOLOURMEM			0x08000

#define SAMPLEADRESS			(0x40000)

#define ATTICADDRESS			0x08000000

#endif
