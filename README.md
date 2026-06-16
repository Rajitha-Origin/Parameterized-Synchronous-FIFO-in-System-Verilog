# Parameterized-Synchronous-FIFO-in-System-Verilog
Designed and verified parameterized synchronous FIFOs (counter-based and pointer-based) in SystemVerilog with overflow/underflow detection, assertions, functional coverage, and scoreboard-based verification.


This project implements a parameterized synchronous FIFO (First-In First-Out) using SystemVerilog. Two FIFO architectures were developed and verified:

* Counter-Based FIFO
* Pointer-Comparison FIFO

## Features

* Parameterized FIFO Depth and Data Width
* Full and Empty Detection
* Overflow and Underflow Handling
* Simultaneous Read/Write Support
* Assertion-Based Verification (SVA)
* Functional Coverage
* Self-Checking Scoreboard

## Verification

The design was verified using a SystemVerilog testbench with:

* Directed and random test scenarios
* Assertions for protocol and boundary checks
* Functional coverage for FIFO events
* Scoreboard-based data integrity checking

## Tools

* SystemVerilog
* EDA Playground / Any SV-compliant simulator

## Run

Compile and run the RTL and testbench files using any SystemVerilog simulator.

This project demonstrates RTL design, FIFO architecture, assertions, functional coverage, and verification methodologies commonly used in VLSI Design and Verification flows.

