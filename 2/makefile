AS := nasm
ASFLAGS := -f elf64 -F DWARF -g -Wall
LD := ld 
LDFLAGS := -g
TARGET := AlternateSum

.PHONY: all clean
all: $(TARGET)

#assembly
AlternateSum.o: AlternateSum.asm
	$(AS) $(ASFLAGS) $<

# linking
$(TARGET): AlternateSum.o
	$(LD) $(LDFLAGS) $< -o $@

clean:
	rm -rf *.o $(TARGET)
