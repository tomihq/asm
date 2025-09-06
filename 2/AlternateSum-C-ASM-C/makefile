AS := nasm
ASFLAGS := -f elf64 -F dwarf -g
CC := gcc
CFLAGS := -Wall -g
TARGET := main

.PHONY: all clean
all: $(TARGET)

# Ensamblador
AlternateSum.o: AlternateSum.asm
	$(AS) $(ASFLAGS) $< -o $@

# C
functions.o: functions.c
	$(CC) $(CFLAGS) -c $< -o $@

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@

# Linking
$(TARGET): main.o AlternateSum.o functions.o
	$(CC) $^ -o $@

clean:
	rm -f *.o $(TARGET)
