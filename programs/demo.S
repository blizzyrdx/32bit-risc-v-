# RV32I-subset demo program
# Computes 10 + 9 + ... + 1 = 55.
# Result goes into x10 (a0) and data memory address 0.

    addi x1,  x0, 10      # counter = 10
    addi x2,  x0, 0       # sum = 0
loop:
    add  x2,  x2, x1      # sum += counter
    addi x1,  x1, -1      # counter--
    bne  x1,  x0, loop    # loop until counter == 0
    add  x10, x0, x2      # a0 = sum
    sw   x10, 0(x0)       # memory[0] = sum
    ebreak                 # halt simulation / FPGA core
