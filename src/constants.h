#ifndef __CONSTANTS_H
#define __CONSTANTS_H

#define SCREEN					0x05000	// 50*552 = #27600 = $6bd0 = ~$6c00

#define PALETTE					0xcc00

#define SINETEMP				0xe000

#define TEXTUREMEM				0x10000	// $6000
#define GRADIENTMEM             0x16000	// $1800
#define BUMPMEM					0x18000 // $6000
#define GFXMEM					0x1f000	// $0440

#define SAMPLEADRESS			0x40000

#define SLICESINUSES			0x20000 // 48*$0200 = $6000

// theoretical maximum number of sprites:
// $2000/25 = 327

// 327 - 40 = 287
// 287/4 = 71 sprites

//327/2 = 163 RRBSCREENWIDTH

// mem = 2*(20+(2*128))
// 25 * 552 = $35e8

#define SCREENWIDTH				20
#define RRBSPRITES				128
#define RRBSCREENWIDTH			(SCREENWIDTH+2*RRBSPRITES)	// 276

#define SCREENWIDTH2			(2*SCREENWIDTH)				// 40
#define RRBSPRITES2				(2*RRBSPRITES)				// 256
#define RRBSCREENWIDTH2			(2*RRBSCREENWIDTH)			// 552

#define COLOR_RAM				0xff80000
#define COLOR_RAM_OFFSET		0x0800
#define SAFE_COLOR_RAM			(COLOR_RAM + COLOR_RAM_OFFSET)
#define SAFE_COLOR_RAM_IN1MB	(SAFE_COLOR_RAM - $ff00000)	

#define MAPPEDCOLOURMEM			0x08000

#define ATTICADDRESS			0x08000000

#endif
