# RISC-V Single Cycle RV32I core

This is a Single Cycle processor running the RV32I implementation, hence a 32-bits cpu, written in __SystemVerilog__. It was made for learning purpouses, it's not intended for production.

## Thanks to

@BrunoLevy and his amazing tutorial [From Blinker to RiscV](https://github.com/BrunoLevy/learn-fpga/blob/master/FemtoRV/TUTORIALS/FROM_BLINKER_TO_RISCV/README.md).

Although that design is very different from the one made in this repo (that tutorial uses a monolithic approach to build the RiscV cpu, whereas I use modular approach), I reused a lot of concepts and code from that tutorial, including the _Memory mapped devices_ idea and the GNU toolchain makefiles.

## RISC-V reference

I recommend 100% to read the [RISC-V Reference Manual](https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf), maybe not complete but those sections mentioning the RV32I implementation.

## Architecture

The architecture was heavily inspired in the 32-bits [Single Cycle MIPS processor](https://media.cheggcdn.com/media/b82/b820d7ac-b4c9-4dd7-af10-e3b3fbe250ff/phpPVaajI) explained in [Digital Design and Computer Architecture book](https://www.amazon.com/Digital-Design-Computer-Architecture-Harris/dp/0123944244/ref=pd_lpo_1?pd_rd_w=SEXjq&content-id=amzn1.sym.116f529c-aa4d-4763-b2b6-4d614ec7dc00&pf_rd_p=116f529c-aa4d-4763-b2b6-4d614ec7dc00&pf_rd_r=82ZAPW9VP21TKQM08AAT&pd_rd_wg=9EFiQ&pd_rd_r=75b9df90-d341-4fb2-b6dd-8ef3d3fa4219&pd_rd_i=0123944244&psc=1). Note that instruction and data are stored in separate memories.

## FPGA Board

Any board should be compatible that has enough LUT's.
This is running on the __Digilent Basys 3__ board and uses
a little bit less than 1,000 LUT's without considering the slow clock circuit.

## Top module and RiscV module

The top module is _RiscVTop.sv_, which includes the wiring to the slow clock, the 7-segments displays and some leds. The cpu itself is the _RiscV.sv_ module which also includes the Instruction Memory and the Data Memory.

## Programming using the GNU Toolchain

I documented the steps in [this repository](https://github.com/martinKindall/compile-for-risc-v-gnu).