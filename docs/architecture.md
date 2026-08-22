# Architecture Notes

## Datapath

The processor is a single-cycle RV32I-subset design. Every non-halt instruction completes one architectural instruction per rising clock edge.

```text
                +------------------+
PC -----------> | Instruction ROM  | ---- instruction ----+
|               +------------------+                       |
|                                                          v
|                                                     +---------+
|                                                     | Decoder |
|                                                     +---------+
|                                                          |
|                 +------------------+                     |
|                 | Register File    | <---- writeback ----+
|                 | x0 ... x31       |
|                 +------------------+
|                      |        |
|                    rs1       rs2
|                      |        |
|                      v        v
|                    +------------+
| immediate -------> |    ALU     | ---- address/result ---+
|                    +------------+                        |
|                                                          v
|                                                  +---------------+
|                                                  |   Data RAM    |
|                                                  +---------------+
|                                                          |
+--------------------- PC + immediate / PC + 4 <-----------+
```

## Architectural state

- 32 x 32-bit integer registers
- `x0` hard-wired to zero
- 32-bit program counter
- instruction ROM
- word-addressable data RAM

## Important simplifications

- single-cycle datapath
- no byte or half-word loads/stores
- no shifts yet
- no `JALR`
- no CSRs, interrupts, privilege modes, MMU, cache, or pipeline
- asynchronous memory reads for simplicity

These simplifications are deliberate. The project is meant to become a platform that I can extend step by step rather than a black-box CPU I cannot explain in an interview.
