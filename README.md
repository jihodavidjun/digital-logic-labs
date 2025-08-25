# Digital Logic in Verilog

This repository contains simple Verilog projects that I designed and simulated as part of my learning in digital logic and hardware description languages.  
All modules include testbenches and simulation waveforms generated with **Icarus Verilog** and **GTKWave**.

---

## Projects

### 1. ALU (Arithmetic Logic Unit)
- 8-bit ALU supporting operations such as ADD, SUB, AND, OR, XOR.
- Implemented with a `case` statement selecting operation based on an opcode.
- Verified using a testbench (`alu_tb.v`) that applies different inputs and opcodes.
- Waveform screenshots included in `/waveforms`.

### 2. Counter
- 4-bit synchronous counter with reset.
- Demonstrates sequential logic and flip-flop design.
- Testbench (`counter_tb.v`) applies clock and reset signals.
- Simulated with GTKWave to visualize counting sequence.

### 3. FSM (Finite State Machine) *(planned)*
- Simple state machine example (traffic light controller or vending machine).
- To be added in future commits.

---

## Folder Structure
alu.v # ALU design

alu_tb.v # ALU testbench

counter.v # Counter design

counter_tb.v # Counter testbench

waveforms/ # Screenshots of GTKWave simulations

README.md


---

## Tools Used
- **Icarus Verilog (iverilog, vvp)** – compile and run Verilog code.
- **GTKWave** – view waveforms and confirm behavior.
- (Optional) **EDA Playground** – quick online simulation.

---

## Example Run
```bash
# Compile and run ALU with testbench
iverilog -o alu_test alu.v alu_tb.v
vvp alu_test

# View waveform
gtkwave alu.vcd
```
---

## Motivation
As an Electrical Engineering student, I am building a foundation in hardware description languages and digital logic design.  
I began learning Verilog through self-study and HDLBits practice, and this repository is my extension into designing and simulating complete modules with testbenches.  
This demonstrates:
- Combinational logic (ALU)  
- Sequential logic (counters, FSMs)  
- Verification with testbenches and waveform analysis
