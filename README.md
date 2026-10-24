# UVM_FIFO_Verification
Comprehensive UVM-based verification environment for a Synchronous FIFO design featuring 100% functional, code, and assertion coverage with SVA properties, coverage collector, scoreboard, and custom sequences.

## Project Overview
This repository presents a robust **UVM (Universal Verification Methodology)** verification environment built to validate a **Synchronous FIFO** design (`FIFO_WIDTH = 16`, `FIFO_DEPTH = 8`)[cite: 47]. 

The primary goal of this project was to establish a fully automated Verification Environment capable of driving constrained-random and directed scenarios, detecting RTL bugs, validating internal design assertions, and achieving **100% Functional, Code, and Assertion Coverage**[cite: 47, 57, 59].

---

## Verification Architecture & Data Flow

The verification environment is designed according to UVM guidelines and is structured as follows:

```text
                                +---------------------------------------------------+
                                |                    FIFO_test                      |
                                |  +---------------------------------------------+  |
                                |  |                  FIFO_env                   |  |
                                |  |  +------------------+  +-----------------+  |  |
                                |  |  | FIFO_scoreboard  |  |  FIFO_coverage  |  |  |
                                |  |  +--------^---------+  +--------^--------+  |  |
                                |  |           | (Analysis)          | (Analysis)|  |
                                |  |  +--------+---------------------+--------+  |  |
                                |  |  |                FIFO_agent             |  |  |
                                |  |  |  +--------------+   +--------------+  |  |  |
                                |  |  |  | FIFO_monitor |   | FIFO_driver  |  |  |  |
                                |  |  |  +-------^------+   +-------+------+  |  |  |
                                |  |  +----------|------------------|---------+  |  |
                                |  +-------------|------------------|------------+  |
                                +----------------|------------------|---------------+
                                                 | (Virtual IF)     | (Virtual IF)
                                +----------------v------------------v---------------+
                                |                     FIFO_if                       |
                                +------------------------+--------------------------+
                                                         |
                                +------------------------v--------------------------+
                                |                    FIFO (DUT)                     |
                                |              (Bound to FIFO_sva)                  |
                                +---------------------------------------------------+

```

### Environment Components

* **Top Module (`top.sv`)**: Generates clock, instantiates `FIFO_if` and `DUT`, binds SystemVerilog Assertions (`FIFO_sva`), sets the virtual interface in `uvm_config_db`, and starts the UVM test execution.


* **UVM Test (`FIFO_test`)**: Manages simulation phases, configures `FIFO_config`, and sequentially executes 5 distinct stimulus sequences.


* **Sequencer & Driver (`FIFO_seq` & `FIFO_driver`)**: The driver pulls items from the sequencer and drives input signals (`rst_n`, `wr_en`, `rd_en`, `data_in`) onto the interface precisely at `negedge clk` to avoid setup/hold race conditions.


* **Monitor (`FIFO_monitor`)**: Samples interface signals after a 1 ns delay from `posedge clk` to ensure stable responses, encapsulates them into response transaction items, and broadcasts them via analysis ports.


* **Scoreboard (`FIFO_scoreboard`)**: Incorporates an internal cycle-accurate reference model (`ref_model`) to predict outputs (`data_out`, status flags, error flags) and performs real-time comparison with DUT responses.


* **Coverage Collector (`FIFO_coverage`)**: Observes transactions to sample 9 coverpoints and 7 cross-coverage bins.


* **Assertions (`FIFO_sva`)**: Bound inside the DUT to continuously monitor flag relationships (using combinational deferred final assertions) and clocked pointer boundaries/wraparounds.



---

## Stimulus Strategy & Sequences

The testbench executes a total of **50,003 items** across five specialized sequence phases:

1. **`FIFO_reset_seq`** (3 items): Applies active-low reset for multiple cycles to clear internal pointers, counter, and registered flags.


2. **`FIFO_main_write_only_seq`** (10,000 items): Drives continuous write operations (`wr_en = 1`, `rd_en = 0`) to fill the FIFO, hitting `almostfull`, `full`, and triggering `overflow`.


3. **`FIFO_main_read_only_seq`** (10,000 items): Drains the FIFO (`wr_en = 0`, `rd_en = 1`) to hit `almostempty`, `empty`, and triggering `underflow`.


4. **`FIFO_main_write_read_seq`** (10,000 items): Executes concurrent write and read requests (`wr_en = 1`, `rd_en = 1`) to test simultaneous access boundaries.


5. **`FIFO_main_rand_seq`** (20,000 items): Fully randomized constrained stimulus (70% write probability, 30% read probability, and random resets) ensuring stress testing under massive random traffic.



---

## RTL Bugs Detected and Resolved

By executing the testbench against the initial design (`FIFO_before.v`), six RTL bugs were identified and successfully corrected in the final design (`FIFO.sv`):

| Bug ID | Signal | Issue / Root Cause | Fix Implemented (`FIFO.sv`) |
| --- | --- | --- | --- |
| **BUG_01** | `wr_ack` | Not cleared upon active-low asynchronous reset (`!rst_n`), causing stale/undefined states.

 | Added explicit reset assignment (`wr_ack <= 0`).

 |
| **BUG_02** | `overflow` | Not cleared during reset condition.

 | Added explicit reset assignment (`overflow <= 0`).

 |
| **BUG_03** | `overflow` | Stays asserted continuously after an overflow event even if subsequent valid writes occur.

 | Added `overflow <= 0` inside successful write branch (`count < FIFO_DEPTH`).

 |
| **BUG_04** | `underflow` | Implemented as combinational logic (`assign underflow = empty && rd_en`), creating potential glitches and timing mismatches.

 | Converted into a sequential output driven inside the `always_ff` clock block.

 |
| **BUG_05** | `count` | Internal count failed to update correctly when `{wr_en, rd_en} == 2'b11` occurred on empty or full states.

 | Added explicit handling for concurrent write and read operations based on FIFO state.

 |
| **BUG_06** | `almostfull` | Calculated incorrectly as `count == FIFO_DEPTH - 2` (asserted at 6 elements instead of 7).

 | Corrected threshold condition to `count == FIFO_DEPTH - 1`.

 |

---

## Verification Results & Metrics

All tests passed cleanly with zero scoreboard comparison mismatches and zero UVM errors.

### Coverage Summary

* **Code Coverage (DUT)**: **100.00%** (Branch, Condition, Statement, Toggle).


* **Functional Coverage**: **100.00%** (68 / 68 covergroup bins hit).


* **Assertion Coverage (SVA)**: **100.00%** (11 / 11 properties covered with zero failures).


* **Scoreboard Results**: **50,002 / 50,002** successful transaction checks (0 failures).



---

## How to Run the Simulation

1. Open **QuestaSim / ModelSim**.


2. Navigate to the `sim/` folder:
```bash
cd sim

```


3. Run the DO script:
```tcl
do run.do

```



```

```
