AS := nasm
ASFLAGS := -f elf64 -F DWARF -g -Wall
LD := ld 
LDFLAGS := -g
TARGET := and

.PHONY: all clean
all: $(TARGET)

#assembly
and.o: and.asm
	$(AS) $(ASFLAGS) $<

# linking
$(TARGET): and.o
	$(LD) $(LDFLAGS) $< -o $@

clean:
	rm -rf *.o $(TARGET)
