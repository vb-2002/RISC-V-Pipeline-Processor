# RISC-V-Pipeline-Processor
This project implements a 32-bit pipelined RISC processor in SystemVerilog, designed as part of a self-driven learning initiative. The processor supports a 5-stage pipeline — Fetch, Decode, Execute, Memory, and Write Back — with modules for hazard detection, data forwarding, and branch control.

# RV32I Instruction Set Documentation

This repository documents a subset of the RISC-V RV32I instruction set, including binary encoding, format, description, and implementation. Useful for developing simulators, assemblers, or hardware logic for RV32I cores.

---

## Supported Instructions

Each instruction includes:
- Binary encoding (bit field table)
- Assembly format
- Description
- Pseudo-code style implementation

---

## Arithmetic Instructions

### `add rd, rs1, rs2`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | rs2    | rs1    | 000    | rd   | 0110011  |

**Description**: Adds the values in `rs1` and `rs2` and stores the result in `rd`.

**Implementation**:  
`x[rd] = x[rs1] + x[rs2]`

---

### `sub rd, rs1, rs2`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | rs2    | rs1    | 000    | rd   | 0110011  |

**Description**: Subtracts `rs2` from `rs1` and stores the result in `rd`.

**Implementation**:  
`x[rd] = x[rs1] - x[rs2]`

---

### `addi rd, rs1, imm`

| Bits     | 31–20       | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|-------------|--------|--------|------|----------|
| Value    | imm[11:0]   | rs1    | 000    | rd   | 0010011  |

**Description**: Adds the 12-bit sign-extended immediate to `rs1` and stores the result in `rd`.

**Implementation**:  
`x[rd] = x[rs1] + sext(immediate)`

---

## Logical Instructions

### `or rd, rs1, rs2`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | rs2    | rs1    | 110    | rd   | 0110011  |

**Description**: Bitwise OR of `rs1` and `rs2`.

**Implementation**:  
`x[rd] = x[rs1] | x[rs2]`

---

### `xor rd, rs1, rs2`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | rs2    | rs1    | 100    | rd   | 0110011  |
|

**Description**: Bitwise XOR of `rs1` and `rs2`.

**Implementation**:  
`x[rd] = x[rs1] ^ x[rs2]`

---

### `andi rd, rs1, imm`

| Bits     | 31–20       | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|-------------|--------|--------|------|----------|
| Value    | imm[11:0]   | rs1    | 111    | rd   | 0010011  |

**Description**: Bitwise AND of `rs1` with sign-extended immediate.

**Implementation**:  
`x[rd] = x[rs1] & sext(immediate)`

---

### `ori rd, rs1, imm`

| Bits     | 31–20       | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|-------------|--------|--------|------|----------|
| Value    | imm[11:0]   | rs1    | 111    | rd   | 0010011  |

**Description**: Bitwise OR of `rs1` with sign-extended immediate.

**Implementation**:  
`x[rd] = x[rs1] | sext(immediate)`

---

### `xori rd, rs1, imm`

| Bits     | 31–20       | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|-------------|--------|--------|------|----------|
| Value    | imm[11:0]   | rs1    | 100    | rd   | 0010011  |

**Description**: Bitwise XOR of `rs1` with sign-extended immediate.

**Implementation**:  
`x[rd] = x[rs1] ^ sext(immediate)`

---

## Shift Instructions

### `sll rd, rs1, rs2`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | rs2    | rs1    | 001    | rd   | 0110011  |

**Description**: Logical left shift of `rs1` by lower 5 bits of `rs2`.

**Implementation**:  
`x[rd] = x[rs1] << x[rs2]`

---

### `srl rd, rs1, rs2`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | rs2    | rs1    | 101    | rd   | 0110011  |

**Description**: Logical right shift.

**Implementation**:  
`x[rd] = x[rs1] >>u x[rs2]`

---

### `sra rd, rs1, rs2`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0100000 | rs2    | rs1    | 101    | rd   | 0110011  |

**Description**: Arithmetic right shift of `rs1` by `rs2`.

**Implementation**:  
`x[rd] = x[rs1] >>s x[rs2]`

---

### `slli rd, rs1, shamt`

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | shamt  | rs1    | 001    | rd   | 0010011  |

**Description**: Logical left shift by immediate.

**Implementation**:  
`x[rd] = x[rs1] << shamt`

---

### `srli rd, rs1, shamt`

**Same format as `slli`, with funct3 = `101`**

| Bits     | 31–25   | 24–20 | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|---------|--------|--------|--------|------|----------|
| Value    | 0000000 | shamt  | rs1    | 101    | rd   | 0010011  |

**Implementation**:  
`x[rd] = x[rs1] >>u shamt`

---

## Load/Store Instructions

### `lw rd, offset(rs1)`

| Bits     | 31–20       | 19–15 | 14–12 | 11–7 | 6–0     |
|----------|-------------|--------|--------|------|----------|
| Value    | offset[11:0]| rs1    | 010    | rd   | 0000011  |

**Description**: Load 32-bit word from memory and sign-extend.

**Implementation**:  
`x[rd] = sext(M[x[rs1] + sext(offset)][31:0])`

---

### `sw rs2, offset(rs1)`

|| Bits     | 31–25        | 24–20 | 19–15 | 14–12 | 11–7        | 6–0     |
|----------|--------------|--------|--------|--------|--------------|----------|
| Value    | offset[11:5] | rs2    | rs1    | 010    | offset[4:0]  | 0100011  |

**Description**: Store 32-bit word from `rs2` into memory.

**Implementation**:  
`M[x[rs1] + sext(offset)] = x[rs2][31:0]`

---

## Notes

- All immediate fields are sign-extended unless stated.
- Overflow is ignored (wrap-around).
- Conforms to RISC-V Unprivileged ISA Spec v2.2.
