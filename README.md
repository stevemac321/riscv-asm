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

# Clone the QEMU repository
git clone https://git.qemu.org/git/qemu.git
cd qemu

# Configure the build for RISC-V target only (adjust as needed)
./configure --target-list=riscv64-softmmu,riscv32-softmmu --enable-debug

# Build QEMU
make -j$(nproc)

# Install (requires sudo)
# sudo make install


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
## Navigating the QEMU Source Repository to virt.c and Understanding Memory-Mapped Devices

After building QEMU from source, you might want to explore how the RISC-V `virt` machine is emulated, especially to understand the memory-mapped devices QEMU provides during emulation.

### How to Find `virt.c`

1. **Locate the QEMU source root** — this is the directory where you cloned the QEMU repository.

2. **Navigate to the RISC-V hardware emulation folder:**

3. **Open the `virt.c` file:**

This file defines the implementation of the `virt` machine, including its devices, memory regions, and interrupt controllers.

### Key Items in `virt.c`

- **Memory-Mapped Devices:**

The `virt` machine exposes several devices mapped at fixed physical addresses. Some important ones include:

- **CLINT (Core Local Interruptor):**
 - Handles software interrupts and timer interrupts.
 - Typically mapped at: `0x02000000`

- **PLIC (Platform-Level Interrupt Controller):**
 - Manages external interrupts.
 - Typically mapped at: `0x0c000000`

- **UART (Serial Console):**
 - Provides console I/O.
 - Usually mapped at: `0x10000000`

- **Address Maps:**

Look for code that calls functions like `memory_region_add_subregion()` or `sysbus_mmio_map()` which map devices to specific memory ranges.

- **Initialization Functions:**

The `virt_init()` function (or similarly named setup functions) registers these devices, sets up interrupt routing, and maps them into the guest physical address space.

### Why This Matters

Understanding these addresses and device names helps when writing assembly or bare-metal programs running inside QEMU’s RISC-V virt machine. For example, if you want to write to the UART to print characters, you need to know its base address and registers, which are documented or implemented in `virt.c`.

---

By exploring `virt.c`, you can correlate the hardware your code interacts with during QEMU emulation and extend or customize the emulated devices if needed.


## License
GPL version 2
