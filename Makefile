PREFIX := avr-
CC := $(PREFIX)gcc
OBJCOPY := $(PREFIX)objcopy
MCU := -mmcu=atmega328p
CPU_SPEED := -DF_CPU=16000000UL
CFLAGS := $(MCU) $(CPU_SPEED) -Os -I../freeRTOS820/include -MMD -MP -std=gnu99 -D__AVR_ATmega328P__ -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -gstabs
LDFLAGS := $(MCU) $(CPU_SPEED)
UNOPORT := /dev/ttyACM0 
FLASHER := avrdude -F -V -c arduino -p ATMEGA328P -P $(UNOPORT) -b 115200 -U flash:w:
RM := rm -rf
MKDIR := mkdir -p

FREERTOSDIR := ../freeRTOS820

FREERTOSSRCS := \
$(FREERTOSDIR)/tasks.c \
$(FREERTOSDIR)/queue.c \
$(FREERTOSDIR)/list.c  \
$(FREERTOSDIR)/lib_io/serial.c \
$(FREERTOSDIR)/MemMang/heap_4.c \
$(FREERTOSDIR)/lib_time/time.c \
$(FREERTOSDIR)/portable/port.c \
$(FREERTOSDIR)/lib_time/system_time.c \
$(FREERTOSDIR)/lib_hd44780/hd44780.c

FREERTOSASMS := \
$(FREERTOSDIR)/lib_time/system_tick.S


FREERTOSOBJS := $(subst .c,.o,$(subst $(FREERTOSDIR),FreeRTOS,$(FREERTOSSRCS)))
FREERTOSDEBS := $(subst .c,.d,$(subst $(FREERTOSDIR),FreeRTOS,$(FREERTOSSRCS)))

OBJS := main.o
DEBS := $(subst .o,.d,$OBJS)

default: main.hex

$(FREERTOSOBJS): FreeRTOS/%.o: $(FREERTOSDIR)/%.c
	$(MKDIR) $(dir $@)
	$(CC) $(CFLAGS) -c -o "$@" "$<" 

main.elf: $(OBJS) $(FREERTOSOBJS) $(FREERTOSASMS)
	$(CC) $(LDFLAGS) -o $@ $^

main.hex: main.elf
	$(OBJCOPY) -O ihex -R .eeprom main.elf main.hex

install: main.hex
	$(FLASHER)main.hex

clean:
	$(RM) *.[od] FreeRTOS main.hex main.elf

view:
	screen /dev/ttyACM0 115200

ifneq ($(MAKECMDGOALS),clean)
-include $(FREERTOSDEBS)
-include $(DEBS)
endif
