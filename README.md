# Digital Logic in Verilog

This repository contains a collection of Verilog projects that I designed and simulated as part of learning digital logic and hardware description languages.  
The projects start from foundational combinational and sequential circuits and extend to applied finite state machines (FSMs).  
Each design includes a corresponding testbench and simulation waveforms generated with **Icarus Verilog** and **GTKWave** (or **EDA Playground**).

---

## Projects

### 1. ALU (Arithmetic Logic Unit) – Combinational
- 8-bit ALU supporting operations such as ADD, SUB, AND, OR, XOR.  
- Demonstrates combinational logic and use of `case` statements.  
- Files: `alu.v`, `alu_tb.v`  
- Verified with a testbench and waveform outputs.  
- **I/O:** `a[7:0]`, `b[7:0]`, `op[2:0]` -> `result[7:0]`, `carry_out`, `zero`  
- **Ops:** 000=ADD, 001=SUB, 010=AND, 011=OR, 100=XOR  
- **Run:** `iverilog -o alu_test alu.v alu_tb.v && vvp alu_test && gtkwave alu.vcd`, or run online on [EDA Playground](https://edaplayground.com) (paste `alu.v` as Design and `alu_tb.v` as Testbench, select Icarus Verilog + EPWave).  
- **Waveform:** see `waveforms/alu.png`  

### 2. Counter – Sequential
- 4-bit synchronous up-counter with synchronous active-high reset.  
- Demonstrates sequential logic and clocked behavior (`posedge clk`).  
- Files: `counter.v`, `counter_tb.v`  
- **I/O:** `clk`, `rst` -> `q[3:0]`  
- **Behavior:**  
  - On each rising edge of `clk`:  
    - If `rst=1`, counter resets to 0.  
    - Else, counter increments by 1 (wraps from 15 → 0).  
- **Run:** `iverilog -o counter_test counter.v counter_tb.v && vvp counter_test && gtkwave counter.vcd`, or run online on [EDA Playground](https://edaplayground.com) (paste `counter.v` as Design and `counter_tb.v` as Testbench, select Icarus Verilog + EPWave).  
- **Waveform:** see `waveforms/counter.png`  

### 3. Heartbeat Counter – FSM
- Digital circuit inspired by my ECG biopatch research.  
- Counts simulated heartbeat pulses (`pulse_in`) over a time window to compute beats per minute (BPM).  
- Demonstrates applied FSM design and event-driven counting.  
- Files: `heartbeat_counter.v`, `heartbeat_counter_tb.v`  
- **I/O:** `clk`, `rst`, `pulse_in` -> `bpm[7:0]`  
- **Behavior:**  
  - On each detected pulse, increment beat counter.  
  - After one “measurement window” (scaled in testbench), update BPM output and reset counter.  
- **Run:** `iverilog -o heartbeat_test heartbeat_counter.v heartbeat_counter_tb.v && vvp heartbeat_test && gtkwave heartbeat_counter.vcd`, or run online on [EDA Playground](https://edaplayground.com).  
- **Waveform:** see `waveforms/heartbeat_counter.png`  

### 4. Mini RISC-V – Datapath + Control
- Simplified RISC-V CPU core (subset of instructions).  
- Integrates ALU, register file, and FSM-based control logic.  
- Demonstrates combination of datapath design and instruction sequencing.  
- Files: `mini_riscv.v`, `mini_riscv_tb.v`  
- **I/O:** `clk`, `rst`, `instr[31:0]` -> `reg_out` (observed in testbench)  
- **Behavior:**  
  - Supports a small instruction set (e.g., ADD, SUB, AND, OR).  
  - FSM control unit fetches, decodes, and executes instructions step by step.  
- **Run:** `iverilog -o risc_test mini_riscv.v mini_riscv_tb.v && vvp risc_test && gtkwave mini_riscv.vcd`, or run online on [EDA Playground](https://edaplayground.com).  
- **Waveform:** see `waveforms/mini_riscv.png`  
---

## Folder Structure
README.md

alu.v + alu_tb.v # combinational foundation (ALU)

counter.v + counter_tb.v # sequential foundation (Counter)

heartbeat_counter.v + heartbeat_counter_tb.v # applied FSM (bio-inspired project)

mini_riscv.v + mini_riscv_tb.v # applied datapath + control FSM (computer architecture)

waveforms/ # screenshots of simulation waveforms

---

## Tools Used
- **Icarus Verilog (iverilog, vvp)** – compile and run Verilog code  
- **GTKWave** – view simulation waveforms locally  
- **EDA Playground** – online simulator for running and sharing code without installs    

---

## Motivation
I began learning Verilog through self-study and HDLBits practice, and expanded into building my own complete projects.  
I first implemented foundational designs (ALU, Counter), then extended to **personalized applied projects** inspired by my experiences in **signal processing** and **computer architecture**:  
- a Heartbeat Counter (bio-inspired FSM, tied to my ECG biopatch research), and  
- a Mini RISC-V core (datapath + FSM control).  
