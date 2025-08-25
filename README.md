# Digital Logic in Verilog

This repository contains a collection of Verilog projects that I designed and simulated as part of learning digital logic and hardware description languages.  
The projects start from foundational combinational and sequential circuits and extend to applied finite state machines (FSMs).  
Each design includes a corresponding testbench and simulation waveforms generated with **Icarus Verilog** and **GTKWave**.

---

## Projects

### 1. ALU (Arithmetic Logic Unit) – Combinational
- 8-bit ALU supporting operations such as ADD, SUB, AND, OR, XOR.  
- Demonstrates combinational logic and use of `case` statements.  
- Files: `alu.v`, `alu_tb.v`  
- Verified with a testbench and waveform outputs.  

### 2. Counter – Sequential
- 4-bit synchronous counter with reset.  
- Demonstrates sequential logic and clocked behavior (`posedge clk`).  
- Files: `counter.v`, `counter_tb.v`  

### 3. Traffic Light Controller – FSM
- Models a traffic light system with states: Green → Yellow → Red.  
- Demonstrates FSM design and conditional transitions.  
- Files: `fsm_traffic.v`, `fsm_traffic_tb.v`  

### 4. Vending Machine Controller – FSM (Planned)
- Accepts coin inputs (nickel, dime, quarter).  
- Accumulates value until target price, then asserts a “dispense” output.  
- Demonstrates more complex FSM design with multiple inputs/outputs.  
- Files: `vending_machine.v`, `vending_machine_tb.v`  

---

## Folder Structure
README.md

alu.v + alu_tb.v # combinational foundation

counter.v + counter_tb.v # sequential foundation

fsm_traffic.v + tb.v # first applied FSM

vending_machine.v + tb.v # second applied FSM (planned)

waveforms/ # screenshots of GTKWave simulations

---

## Tools Used
- **Icarus Verilog (iverilog, vvp)** – compile and run Verilog code  
- **GTKWave** – view simulation waveforms  

---

## Motivation
I began learning Verilog through self-study and HDLBits practice, and expanded into building my own complete projects.  
This repository demonstrates my ability to:
- Design combinational and sequential circuits in Verilog  
- Apply finite state machines (FSMs) to model real-world systems  
- Verify designs with testbenches and waveform analysis  
- Document projects in a professional format for others to use  
