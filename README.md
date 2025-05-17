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

# Install required dependencies (Ubuntu/Debian example)
sudo apt-get update
sudo apt-get install -y git build-essential flex bison python3

# Clone QEMU repo if not already done
git clone https://git.qemu.org/git/qemu.git
cd qemu

# Clean previous build artifacts if any
make clean

# Configure QEMU with debug enabled
./configure --enable-debug

# Build QEMU
make -j$(nproc)

# Install QEMU system-wide
sudo make install

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
## Debugging QEMU Startup Code

When debugging QEMU itself, keep in mind that QEMU’s startup and initialization code runs independently of any guest binaries like `hello.elf`. This means:

- QEMU initializes its virtual hardware, memory mappings, and device emulation *before* your guest program starts executing.
- Setting breakpoints in QEMU’s startup code lets you step through how the emulator sets up the virtual machine environment.
- For example, setting a breakpoint at QEMU’s internal `_start` or `main` function allows you to observe early initialization.
- Once QEMU has completed setup, it loads and runs your guest program (`hello.elf` or others).

### Stepping through startup code

To step through QEMU’s startup and initialization:

1. Build QEMU with debugging symbols enabled (`./configure --enable-debug`).
2. Launch QEMU inside GDB or `gdb-multiarch`.
3. Set a breakpoint at `main` or `_start` in the QEMU source.
4. Run QEMU and step through the initialization code before the guest binary runs.
5. This allows inspection of interrupt vector initialization, device setup, and other low-level emulator details.

After startup completes, the guest program begins execution, which you can then debug separately.

This method provides insight into both QEMU internals and guest software behavior.
---

## Exploring QEMU Source: `virt.c` and Peripheral Emulation

To understand how QEMU emulates the RISC-V `virt` machine and its devices, including memory-mapped peripherals, explore the following files and directories in the QEMU source tree:

### 🧠 1. `virt.c` – Platform Definition

Located at:

```
hw/riscv/virt.c
```

This file defines the RISC-V `virt` board. It sets up:
- Memory layout
- CPU configuration
- UART (serial console)
- PLIC (interrupt controller)
- CLINT (core-local interrupts)
- Flash and RAM devices
- Memory-mapped I/O regions

Look for functions like `virt_machine_init()` or `virt_board_init()` to see how devices are registered and where they're mapped.

---

### 🔌 2. `hw/gpio/` – GPIO Device Models

Located at:

```
hw/gpio/
```

This directory contains emulations of General Purpose Input/Output (GPIO) controllers, which simulate digital I/O pins like LEDs, buttons, and sensors.

Examples include:
- `sifive_gpio.c`: SiFive RISC-V GPIO controller
- `pl061.c`: ARM PrimeCell PL061 GPIO

These are instantiated in `virt.c` (or other platform files) using calls like:

```c
sysbus_create_simple("sifive,gpio", address, irq);
```

GPIOs can be memory-mapped and interacted with in RISC-V code, making this a great area for experimenting with device-level debugging or extension.

---

### 📦 3. Other Useful Directories to Explore

- `hw/char/` – UART and serial device models (e.g., `ns16550.c` for serial output)
- `hw/intc/` – Interrupt controllers like PLIC or CLINT
- `include/hw/` – Header files that describe device interfaces
- `docs/system/target-riscv.rst` – Documentation on the `virt` board and its components

---

Understanding these areas gives you a complete view of how RISC-V hardware is emulated in QEMU and how your code interacts with these virtual devices.



## License
GPL version 2
