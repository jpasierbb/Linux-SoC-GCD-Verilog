# SoC GCD Emulator for Linux

### Project Description
This project was developed as part of my studies at the Warsaw University of Technology. It focuses on creating a custom System on Chip (SoC) emulator that calculates the Greatest Common Divisor (GCD) of two numbers using a Verilog module. The project integrates this hardware functionality with a Linux kernel module and a user-space application for testing, simulating efficient hardware-software communication in a custom Linux environment.

### Objectives
The main objectives of this project include:
1. **Verilog GCD Module**: Implement a hardware module in Verilog to calculate the GCD using the Euclidean algorithm. Calculation begins when values are written to designated registers.
2. **Linux Kernel Module**: Integrate the GCD module with a Linux kernel module to provide access to the hardware registers via the `/sys` filesystem.
3. **Testing Application**: Create a user-space application to test GCD calculations, monitor status, and display results.

### System Structure
1. **Verilog GCD Module (`gpioemu.v`), (`gpioemu_tb.v`)**:
   - Computes the GCD of two 32-bit integers stored in registers A1 and A2.
   - Outputs the result in register W and operation status in register S.
2. **Linux Kernel Module (`kernel_module.c`)**:
   - Interfaces with the Verilog module using the `/sys` filesystem for controlled read/write access.
3. **Testing Application (`main.c`)**:
   - User-space application for inputting values, monitoring the GCD calculation status, and outputting results.
