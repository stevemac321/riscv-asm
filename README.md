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
### 🐛 Debugging QEMU Startup and Guest Entry

To debug the QEMU startup process and catch when guest execution begins, follow these steps.

Assuming the `qemu-system-riscv64` debug binary is in your `build` directory:

```sh
# Launch GDB with the QEMU binary
cd qemu
gdb ./build/qemu-system-riscv64
```

Then in `gdb`, set breakpoints and run it with your guest ELF:

```gdb
(gdb) break riscv_harts_cpu_reset
(gdb) break cpu_exec
(gdb) break riscv_setup_rom_reset_vec
(gdb) run -machine virt -nographic -bios none -kernel <path>hello.elf (or the name of your .elf file)
```

---

### 🧠 What These Breakpoints Do

- `riscv_harts_cpu_reset`:  
  This breakpoint catches the moment QEMU resets the virtual CPU, which is the first step of guest startup. It's roughly equivalent to a hardware `ResetHandler`.

  - `riscv_setup_rom_reset_vec`:  
  This breakpoint is just an example of an interesting breakpoint between `riscv_harts_cpu_reset` and `cpu_exec`.  This function initializes the CPU's reset vector, which is the address where execution begins after a CPU reset — analogous to the "ResetHandler" in physical hardware.

- `cpu_exec`:  
  This breakpoint is hit when QEMU begins executing the guest code — where it starts interpreting or translating RISC-V instructions. This marks the start of guest-side activity (e.g., your `hello.elf` `_start`).

---

This setup allows you to step through:

1. QEMU’s CPU reset logic (`riscv_harts_cpu_reset`)
2. The handoff to guest execution (`cpu_exec`)
3. Then step directly into the guest binary’s startup (`_start`)

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
