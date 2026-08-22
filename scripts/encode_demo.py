#!/usr/bin/env python3
"""Generate programs/demo.hex without requiring a RISC-V toolchain."""
from pathlib import Path


def enc_i(imm, rs1, funct3, rd, opcode=0x13):
    imm &= 0xFFF
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def enc_r(funct7, rs2, rs1, funct3, rd, opcode=0x33):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def enc_s(imm, rs2, rs1, funct3, opcode=0x23):
    imm &= 0xFFF
    return ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | ((imm & 0x1F) << 7) | opcode


def enc_b(imm, rs2, rs1, funct3, opcode=0x63):
    imm &= 0x1FFF
    return (((imm >> 12) & 1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | \
           (rs1 << 15) | (funct3 << 12) | (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 1) << 7) | opcode


program = [
    enc_i(10, 0, 0b000, 1),      # addi x1,x0,10
    enc_i(0, 0, 0b000, 2),       # addi x2,x0,0
    enc_r(0, 1, 2, 0b000, 2),    # add x2,x2,x1
    enc_i(-1, 1, 0b000, 1),      # addi x1,x1,-1
    enc_b(-8, 0, 1, 0b001),      # bne x1,x0,loop
    enc_r(0, 2, 0, 0b000, 10),   # add x10,x0,x2
    enc_s(0, 10, 0, 0b010),      # sw x10,0(x0)
    0x00100073,                   # ebreak
]

out = Path(__file__).resolve().parents[1] / "programs" / "demo.hex"
out.write_text("\n".join(f"{word:08x}" for word in program) + "\n")
print(f"Wrote {out}")
