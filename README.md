# RISC-V Assembly Debugging with QEMU and GDB in WSL2

This repository demonstrates how to build and debug a minimal RISC-V assembly program using `riscv64-unknown-elf` toolchain, QEMU, and `gdb-multiarch` within WSL2. It includes:

- Assembly source file
- Linker script
- Makefile
- GDB debug script

---

## Prerequisites

Ensure you have WSL2 installed and a Linux distro set up (Ubuntu recommended).

### Step 1: Install RISC-V Toolchain

```bash
sudo apt update
sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```

### Step 2: Install QEMU and GDB

```bash
sudo apt install qemu-system-misc gdb-multiarch
```

---

## Project Files

### Step 3: Source Code (`hello.s`)

A minimal RISC-V assembly program that writes "Hello, world!" to stdout using the SBI (Supervisor Binary Interface).

### Step 4: Linker Script (`link.ld`)

Defines the memory layout and entry point `_start`.

### Step 5: Makefile

Handles building `hello.elf` using `riscv64-unknown-elf-as` and `ld`. Targets include:

- `make` – builds `hello.elf`
- `make clean` – removes build artifacts

### Step 6: Debug Script (`debug.gdb`)

Contains GDB commands to:

- Connect to QEMU's GDB stub
- Load symbols
- Set architecture
- Break at `_start`

Example contents:

```gdb
file hello.elf
set architecture riscv:rv64
target remote localhost:1234
load
```

---

## Running & Debugging

### Step 7: Launch QEMU with GDB Stub

```bash
qemu-system-riscv64 -M virt -nographic -bios none -kernel hello.elf -s -S
```

- `-s` = shorthand for `-gdb tcp::1234`
- `-S` = freeze CPU at startup (wait for debugger)

### Step 8: Attach GDB

In a second terminal:

```bash
gdb-multiarch -x debug.gdb
```

Then use GDB commands like:

```gdb
continue
stepi
info registers
```

---

## Notes

- To exit QEMU: press `Ctrl+A`, then `X`.
- GDB may emit deprecation warnings (e.g., `target-async`); these can be safely ignored for now.
- For full remote debugging setup, ensure `gdb-multiarch` is in your PATH.

---

## License
GPL version 2
