# RISC-V-Pipeline-Processor
This project implements a 32-bit pipelined RISC processor in SystemVerilog, designed as part of a self-driven learning initiative. The processor supports a 5-stage pipeline — Fetch, Decode, Execute, Memory, and Write Back — with modules for hazard detection, data forwarding, and branch control.

# RV32I Instruction Set Documentation

This repository documents a subset of the RISC-V RV32I instruction set, including encoding, format, description, and implementation behavior for each instruction. The format follows standard RISC-V conventions and is useful for both learning and implementing RISC-V ISA in tools like simulators, assemblers, or hardware descriptions.

---

## 📜 Supported Instructions

Each instruction includes:
- **Binary encoding format**
- **Assembly syntax**
- **Description**
- **Pseudo-code style implementation**

---

### 🧮 Arithmetic Instructions

#### `add rd, rs1, rs2`

| Bits    | Field |
|---------|-------|
| 31–27   | 00000 |
| 26–25   | 00    |
| 24–20   | rs2   |
| 19–15   | rs1   |
| 14–12   | 000   |
| 11–7    | rd    |
| 6–2     | 01100 |
| 1–0     | 11    |

Adds values in `rs1` and `rs2`, result stored in `rd`.

> `x[rd] = x[rs1] + x[rs2]`

---

#### `sub rd, rs1, rs2`

| Bits    | Field |
|---------|-------|
| 31–27   | 01000 |
| 26–25   | 00    |
| ...     | ...   |

Subtracts `rs2` from `rs1`, result stored in `rd`.

> `x[rd] = x[rs1] - x[rs2]`

---

#### `addi rd, rs1, imm`

Adds 12-bit sign-extended immediate to `rs1`, stores result in `rd`.

> `x[rd] = x[rs1] + sext(imm)`

---

### 🔢 Logical Instructions

#### `or rd, rs1, rs2`  
Performs bitwise OR:  
> `x[rd] = x[rs1] | x[rs2]`

#### `xor rd, rs1, rs2`  
Performs bitwise XOR:  
> `x[rd] = x[rs1] ^ x[rs2]`

#### `andi rd, rs1, imm`  
Bitwise AND with sign-extended immediate:  
> `x[rd] = x[rs1] & sext(imm)`

#### `ori rd, rs1, imm`  
Bitwise OR with sign-extended immediate:  
> `x[rd] = x[rs1] | sext(imm)`

#### `xori rd, rs1, imm`  
Bitwise XOR with sign-extended immediate:  
> `x[rd] = x[rs1] ^ sext(imm)`  
> `xori rd, rs1, -1` = `not rd, rs1`

---

### 🔁 Shift Instructions

#### `sll rd, rs1, rs2`  
Shift left logical:  
> `x[rd] = x[rs1] << x[rs2]`

#### `srl rd, rs1, rs2`  
Logical right shift:  
> `x[rd] = x[rs1] >>u x[rs2]`

#### `sra rd, rs1, rs2`  
Arithmetic right shift:  
> `x[rd] = x[rs1] >>s x[rs2]`

#### `slli rd, rs1, shamt`  
Shift left logical immediate:  
> `x[rd] = x[rs1] << shamt`

#### `srli rd, rs1, shamt`  
Logical right shift immediate:  
> `x[rd] = x[rs1] >>u shamt`

---

### 📥 Load Instruction

#### `lw rd, offset(rs1)`

Load 32-bit word from memory at address `rs1 + offset`, sign-extend to `XLEN`:

> `x[rd] = sext(M[x[rs1] + sext(offset)][31:0])`

---

### 📤 Store Instruction

#### `sw rs2, offset(rs1)`

Store 32-bit word from `rs2` into memory:

> `M[x[rs1] + sext(offset)] = x[rs2][31:0]`

---

## 🛠 Notes

- All immediates are sign-extended 12-bit unless specified.
- Overflow is ignored (wrap-around behavior).
- Instructions are based on the [RISC-V Unprivileged ISA Spec v2.2](https://github.com/riscv/riscv-isa-manual).

---

## 📂 License

This project is licensed under the MIT License.

---

## 🤝 Contributions

Feel free to fork and contribute additional RV32I instructions or extensions (like RV32M, RV32F). PRs are welcome!

