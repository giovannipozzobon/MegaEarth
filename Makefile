# -----------------------------------------------------------------------------

megabuild		= 1
attachdebugger	= 0

# -----------------------------------------------------------------------------

MAKE			= make
CP				= cp
MV				= mv
RM				= rm -f
CAT				= cat

SRC_DIR			= ./src
EXE_DIR			= ./exe
BIN_DIR			= ./bin

CC1541			= cc1541
MC				= MegaConvert
MEGAADDRESS		= megatool -a
MEGACRUNCH		= megatool -c
MEGAIFFL		= megatool -i
EL				= etherload
XMEGA65			= D:\PCTOOLS\xemu\xmega65.exe
MEGAFTP			= mega65_ftp -e

.SUFFIXES: .o .s .out .bin .pu .b2 .a

default: all

VPATH = src

# Common source files
ASM_SRCS = decruncher.s iffl.s irqload.s irq_fastload.s irq_main.s startup.s program_asm.s
C_SRCS = main.c dma.c modplay.c dmajobs.c program.c

OBJS = $(ASM_SRCS:%.s=$(EXE_DIR)/%.o) $(C_SRCS:%.c=$(EXE_DIR)/%.o)
OBJS_DEBUG = $(ASM_SRCS:%.s=$(EXE_DIR)/%-debug.o) $(C_SRCS:%.c=$(EXE_DIR)/%-debug.o)

BINFILES  = $(BIN_DIR)/gfx_chars0.bin
BINFILES += $(BIN_DIR)/gfx_pal0.bin
BINFILES += $(BIN_DIR)/song.mod

BINFILESMC  = $(BIN_DIR)/gfx_chars0.bin.addr.mc
BINFILESMC += $(BIN_DIR)/gfx_pal0.bin.addr.mc
BINFILESMC += $(BIN_DIR)/song.mod.addr.mc

# -----------------------------------------------------------------------------

# direction = 3 = CharTopBottomLeftRight
$(BIN_DIR)/gfx_chars0.bin: $(BIN_DIR)/gfx.bin
	$(MC) $< cm1:2 d1:0 cl1:10000 rc1:0


$(BIN_DIR)/alldata.bin: $(BINFILES)
	$(MEGAADDRESS) $(BIN_DIR)/gfx_chars0.bin      00010000
	$(MEGAADDRESS) $(BIN_DIR)/gfx_pal0.bin        0000c000
	$(MEGAADDRESS) $(BIN_DIR)/song.mod            08000000
	$(MEGACRUNCH) $(BIN_DIR)/gfx_chars0.bin.addr
	$(MEGACRUNCH) $(BIN_DIR)/gfx_pal0.bin.addr
	$(MEGACRUNCH) $(BIN_DIR)/song.mod.addr
	$(MEGAIFFL) $(BINFILESMC) $(BIN_DIR)/alldata.bin

$(EXE_DIR)/%.o: %.s
	as6502 --target=mega65 --list-file=$(@:%.o=%.lst) -o $@ $<

$(EXE_DIR)/%.o: %.c
	cc6502 --target=mega65 --code-model=plain -O2 --list-file=$(@:%.o=%.lst) -o $@ $<

$(EXE_DIR)/%-debug.o: %.s
	as6502 --target=mega65 --debug --list-file=$(@:%.o=%.lst) -o $@ $<

$(EXE_DIR)/%-debug.o: %.c
	cc6502 --target=mega65 --debug --list-file=$(@:%.o=%.lst) -o $@ $<

# there are multiple places that need to be changed for the start address:
# ln6502 command line option --load-address 0x1001
# megacrunch start address -f 100e
# scm file   address (#x1001) section (programStart #x1001)

$(EXE_DIR)/cprog.prg: $(OBJS)
	ln6502 --target=mega65 mega65-custom.scm -o $@ $^ --load-address 0x1200 --raw-multiple-memories --cstartup=mystartup --rtattr printf=nofloat --rtattr exit=simplified --output-format=prg --list-file=$(EXE_DIR)/cprog.lst

$(EXE_DIR)/cprog.prg.mc: $(EXE_DIR)/cprog.prg
	$(MEGACRUNCH) -f 1200 $(EXE_DIR)/cprog.prg

# -----------------------------------------------------------------------------

$(EXE_DIR)/cprog.d81: $(EXE_DIR)/cprog.prg.mc  $(BIN_DIR)/alldata.bin
	$(RM) $@
	$(CC1541) -n "cprog" -i " 2024" -d 19 -v\
	 \
	 -f "cprog" -w $(EXE_DIR)/cprog.prg.mc \
	 -f "data" -w $(BIN_DIR)/alldata.bin \
	$@

# -----------------------------------------------------------------------------

run: $(EXE_DIR)/cprog.d81

ifeq ($(megabuild), 1)
	$(MEGAFTP) -c "put .\exe\cprog.d81 cprog.d81" -c "quit"
	$(EL) -m CPROG.D81 -r $(EXE_DIR)/cprog.prg.mc
ifeq ($(attachdebugger), 1)
	m65dbg --device /dev/ttyS2
endif
else
ifeq ($(attachdebugger), 1)
	cmd.exe /c "$(XMEGA65) -uartmon :4510 -autoload -8 $(EXE_DIR)/cprog.d81" & m65dbg -l tcp 4510
else
	cmd.exe /c "$(XMEGA65) -autoload -8 $(EXE_DIR)/cprog.d81"
endif
endif

clean:
	-rm -f $(OBJS) $(OBJS:%.o=%.clst) $(OBJS_DEBUG) $(OBJS_DEBUG:%.o=%.clst) $(BIN_DIR)/*_*.bin
	-rm -f $(EXE_DIR)/cprog.d81 $(EXE_DIR)/cprog.elf $(EXE_DIR)/cprog.prg $(EXE_DIR)/cprog.prg.mc $(EXE_DIR)/cprog.lst $(EXE_DIR)/cprog-debug.lst
