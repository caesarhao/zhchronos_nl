# makefile for msp430
# Jungle

export CROSS_COMPILE = msp430-elf-
export CC 		= $(CROSS_COMPILE)gcc
export CPP 		= $(CROSS_COMPILE)g++
export AS 		= $(CROSS_COMPILE)gcc
export AR 		= $(CROSS_COMPILE)ar
export RANLIB 	= $(CROSS_COMPILE)ranlib
export NM		= $(CROSS_COMPILE)nm
export STRIP 	= $(CROSS_COMPILE)strip
export OBJCOPY 	= $(CROSS_COMPILE)objcopy
export OBJDUMP 	= $(CROSS_COMPILE)objdump
export SIZE 	= $(CROSS_COMPILE)size
export READELF 	= $(CROSS_COMPILE)readelf
export LD 		= $(CROSS_COMPILE)ld

MAKETXT  = srec_cat
# MSP430Flasher name
MSPFLASHER = MSP430Flasher

export CP = cp -p
export MV = mv
export RM = rm


TARGET = zhchronos_nl

MCU    = cc430f6137

SOURCES = $(wildcard *.c) $(wildcard driver/*.c) $(wildcard logic/*.c)
# all the libraries here
LIBS = 
# Include are located in the following directory
INCLUDEDIRS = include driver logic 

INCLUDES = $(addprefix -I, $(INCLUDEDIRS))
# Add or subtract whatever MSPGCC flags you want. There are plenty more
#######################################################################################
CFLAGS   = -mmcu=$(MCU)
CFLAGS	+= -fno-force-addr -finline-limit=1 -fno-schedule-insns
CFLAGS	+=	-fshort-enums -ffunction-sections -fdata-sections -fomit-frame-pointer
CFLAGS	+= -Os -Wall -Wunused $(INCLUDES)
CFLAGS	+= -D__MSP430_6137__ -D__CC430F6137__
CFLAGS	+= -DMRFI_CC430 -DISM_EU -DMAX_APP_PAYLOAD=19 -DMAX_NWK_PAYLOAD=9 -DMAX_HOPS=3 -DMAX_HOPS_FROM_AP=1
CFLAGS	+= -DDEFAULT_JOIN_TOKEN=0x05060708 -DDEFAULT_LINK_TOKEN=0x01020304 -DAPP_AUTO_ACK -DSW_TIMER
CFLAGS	+= -DNUM_CONNECTIONS=1 -DSIZE_INFRAME_Q=2 -DSIZE_OUTFRAME_Q=2
CFLAGS	+= -DEND_DEVICE -DTHIS_DEVICE_ADDRESS="{0x79, 0x56, 0x34, 0x12}"
ASFLAGS  = -mmcu=$(MCU) -x assembler-with-cpp -Wa,-gstabs
LDFLAGS  = -mmcu=$(MCU) -Wl,-Map=$(TARGET).map
LDFLAGS += -Wl,--gc-sections -Wl,-s
########################################################################################

DEPEND = $(SOURCES:.c=.d)
# all the object files
OBJECTS = $(SOURCES:.c=.o)
all: $(TARGET).elf $(TARGET).hex $(TARGET).txt
$(TARGET).elf: $(OBJECTS)
	echo "Linking $@"
	$(CC) $(OBJECTS) $(LDFLAGS) $(LIBS) -o $@
	echo
	echo ">>>> Size of Firmware <<<<"
	$(SIZE) $(TARGET).elf
	echo

%.hex: %.elf
	$(OBJCOPY) -O ihex $< $@

%.txt: %.hex
	$(MAKETXT) -O $@ -TITXT $< -I
#	unix2dos $@

%.o: %.c
	echo "Compiling $<"
	$(CC) -c $(CFLAGS) -o $@ $<

# rule for making assembler source listing, to see the code
%.lst: %.c
	$(CC) -c $(ASFLAGS) -Wa,-anlhd $< > $@
# include the dependencies unless we're going to clean, then forget about them.
ifneq ($(MAKECMDGOALS), clean)
-include $(DEPEND)
endif

# dependencies file
# includes also considered, since some of these are our own
# (otherwise use -MM instead of -M)
%.d: %.c
	echo "Generating dependencies $@ from $<"
	$(CC) -M ${CFLAGS} $< >$@

.SILENT:
.PHONY: clean
clean:
	-$(RM) $(OBJECTS)
	-$(RM) $(TARGET).*
	-$(RM) $(SOURCES:.c=.lst)
	-$(RM) $(DEPEND)

install: $(TARGET).txt
	$(MSPFLASHER) -n $(MCU) -w "$(TARGET).txt" -v -z [VCC]

