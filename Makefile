# Build and run:
#   make
#   make run
#   make release
#   gdb-multiarch -tui -x debug.gdb hello.elf


# Toolchain
AS = riscv64-unknown-elf-as
LD = riscv64-unknown-elf-ld

# Default build flags (debug)
ASFLAGS = -g
LDFLAGS = -g -T link.ld

# Output binary
TARGET = hello.elf
OBJ = hello.o
SOURCE = hello.s

all: $(TARGET)

$(OBJ): $(SOURCE)
	$(AS) $(ASFLAGS) -o $@ $<

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

release: ASFLAGS=        # No -g
release: LDFLAGS= -T link.ld  # No -g
release: clean all       # Rebuild without debug info

run: all
	qemu-system-riscv64 -M virt -nographic -bios none -kernel $(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)
