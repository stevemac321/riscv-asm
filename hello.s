 .section .text
 .globl _start

_start:
    la a0, msg             # Load address of the message

loop:
    lbu a1, 0(a0)          # Load byte from string
    beqz a1, done          # If zero (null terminator), exit loop
    li a2, 0x10000000      # UART0 base address in QEMU virt machine
    sb a1, 0(a2)           # Store byte to UART
    addi a0, a0, 1         # Increment pointer
    j loop                 # Repeat

done:
    j done                 # Infinite loop to stop

    .section .rodata
msg:
    .asciz "Hello from UART!\n"
