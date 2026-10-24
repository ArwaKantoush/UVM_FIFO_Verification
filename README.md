# UVM Verification of a Synchronous FIFO

A UVM verification environment for a synchronous FIFO (`FIFO_WIDTH = 16`, `FIFO_DEPTH = 8`). It drives directed and constrained-random stimulus, checks every output against a reference model, collects functional coverage, and uses bound SystemVerilog assertions. Running it against the original design exposes six RTL bugs; against the fixed design it reaches 100% code, functional and assertion coverage with zero failures.

The full project report (verification plan, waveforms, coverage reports, bug report with before/after code) is in [`UVM_Verification_of_a_Synchronous_FIFO.pdf`](UVM_Verification_of_a_Synchronous_FIFO.pdf).

## Highlights

- 5 UVM sequences, 50,003 items driven in total
- Scoreboard with a cycle-accurate reference model that checks all 8 outputs on every item
- Functional coverage: 9 coverpoints and 7 crosses (68 bins)
- 11 assertions bound into the DUT: 7 clocked properties and 4 deferred final assertions for the combinational flags
- 6 RTL bugs found and fixed

## Repository structure

```
.
├── rtl/
│   ├── FIFO.sv            # fixed design
│   ├── FIFO_before.v      # original design with the 6 bugs
│   └── FIFO_sva.sv        # assertions, bound to the DUT in top.sv
├── tb/
│   ├── top.sv             # clock, interface, DUT, bind, run_test
│   ├── FIFO_if.sv         # interface
│   ├── shared_pkg.sv      # parameters
│   ├── FIFO_config.sv     # configuration object (holds the virtual interface)
│   ├── FIFO_seq_item.sv   # transaction with constraints
│   ├── FIFO_seq.sv        # sequencer
│   ├── FIFO_driver.sv
│   ├── FIFO_monitor.sv
│   ├── FIFO_agent.sv
│   ├── FIFO_scoreboard.sv
│   ├── FIFO_coverage.sv
│   ├── FIFO_env.sv
│   ├── FIFO_test.sv
│   └── sequences/         # reset, write_only, read_only, write_read, rand
├── sim/
│   ├── run.do             # compile, simulate, coverage report
│   ├── src_tb.list        # testbench compile order
│   └── src_dut.list       # DUT, assertions and top
├── UVM_Verification_of_a_Synchronous_FIFO.pdf
└── LICENSE
```

## Testbench architecture

```
top
├── clock generator (10 ns period)
├── FIFO_if
├── FIFO (DUT)  +  FIFO_sva (bound with `bind`)
└── run_test("FIFO_test")

FIFO_test                        starts the sequences below on the agent sequencer
└── FIFO_env
    ├── FIFO_agent
    │   ├── FIFO_seq (sequencer) ──► FIFO_driver ──► FIFO_if      drives rst_n, wr_en, rd_en, data_in
    │   └── FIFO_monitor ◄── FIFO_if                              samples at posedge clk + 1 ns
    │            └── analysis port ──┬──► FIFO_scoreboard (reference model)
    │                                └──► FIFO_coverage   (covergroup)
    └── FIFO_config                  holds the virtual interface (config_db key "CFG")
```

| Component | Role |
|---|---|
| `top` | Generates the clock, instantiates `FIFO_if` and the DUT, binds `FIFO_sva`, stores the virtual interface in `uvm_config_db` and calls `run_test`. |
| `FIFO_test` | Builds the environment and starts the five sequences one after the other. |
| `FIFO_seq_item` | Randomized inputs (`rst_n`, `wr_en`, `rd_en`, `data_in`) and the observed outputs. Constraints: `rst_n` low 3% of the time, `wr_en` high 70%, `rd_en` high 30%. |
| `FIFO_driver` | Drives only the DUT inputs and waits for the next falling clock edge. |
| `FIFO_monitor` | Waits for a rising edge plus 1 ns, so the DUT outputs have settled and the driver has not yet applied the next inputs, then samples all signals. |
| `FIFO_scoreboard` | Reference model (memory, pointers, count). Compares `data_out`, `wr_ack`, `overflow`, `underflow`, `full`, `empty`, `almostfull` and `almostempty` with `!==`. |
| `FIFO_coverage` | Covergroup with 9 coverpoints and 7 crosses. `cp_full_pre` and `cp_empty_pre` sample the FIFO state before each transaction. |
| `FIFO_sva` | Clocked properties for reset, `wr_ack`, `overflow`, `underflow`, pointer wraparound and pointer limits. The combinational flags are checked in an `always_comb` block with `assert final`. |

## Sequences

| Sequence | Items | Stimulus |
|---|---|---|
| `FIFO_reset_seq` | 3 | `rst_n = 0` for several clock edges |
| `FIFO_main_write_only_seq` | 10,000 | `wr_en = 1`, `rd_en = 0` (fills the FIFO, reaches `almostfull`, `full`, `overflow`) |
| `FIFO_main_read_only_seq` | 10,000 | `wr_en = 0`, `rd_en = 1` (drains the FIFO, reaches `almostempty`, `empty`, `underflow`) |
| `FIFO_main_write_read_seq` | 10,000 | `wr_en = 1`, `rd_en = 1` (simultaneous read and write) |
| `FIFO_main_rand_seq` | 20,000 | All inputs randomized with the item constraints |

Only `wr_en` and `rd_en` are forced in the directed sequences. `rst_n` still follows the item constraint, so a random reset (about 3% of the items) can occur in every sequence.

## RTL bugs found and fixed

The testbench was run against `rtl/FIFO_before.v` (original) and `rtl/FIFO.sv` (fixed).

| Bug | Signal | Problem | Fix |
|---|---|---|---|
| BUG_01 | `wr_ack` | Not cleared by reset | `wr_ack <= 0` in the reset branch |
| BUG_02 | `overflow` | Not cleared by reset | `overflow <= 0` in the reset branch |
| BUG_03 | `overflow` | Stayed high after a later accepted write | `overflow <= 0` in the accepted-write branch |
| BUG_04 | `underflow` | Combinational assign (`empty && rd_en`), not a registered output | Registered in the clocked read block, with reset |
| BUG_05 | `count` | Not updated when `wr_en` and `rd_en` are both high | Added the `2'b11` case: +1 when empty, -1 when full, unchanged otherwise |
| BUG_06 | `almostfull` | Compared `count` with `FIFO_DEPTH-2` | Compare with `FIFO_DEPTH-1` |

Against the original design the scoreboard reports 24,608 failed transactions out of 50,002, and the assertions `a_afull` (BUG_06) and `underflow_propert` (BUG_04) fail. Before and after code for each bug is in the report.

## Results (fixed design)

| Metric | Result |
|---|---|
| Code coverage (DUT) | Branch 26/26, condition 16/16, statement 29/29, toggle 106/106 (100%) |
| Functional coverage | 68/68 bins (100%) |
| Assertions | 11/11 pass, 0 failures, all cover directives hit |
| Scoreboard | 50,002 successful, 0 failed |
| UVM report | 0 `UVM_ERROR`, 0 `UVM_FATAL` |

The sequences drive 50,003 items. The scoreboard checks 50,002 of them because the first reset item is applied before the monitor's first sample.

## How to run

Requirements: QuestaSim (tested with 2021.1 and its built-in UVM 1.1d).

```
cd sim
vsim -do run.do        # or: open QuestaSim, cd to sim/, then: do run.do
```

`run.do` compiles the testbench and the design with coverage enabled (`+cover=bcesft`), runs the simulation, saves `FIFO_cov.ucdb` and writes `coverage_rpt.txt`.

Expected end of the transcript:

```
UVM_INFO ... [report_phase] Total successful transactions: 50002
UVM_INFO ... [report_phase] Total failed transactions: 0
```

### Reproduce the bugs

In `sim/src_dut.list` replace `../rtl/FIFO.sv` with `../rtl/FIFO_before.v` and run `do run.do` again. The transcript then shows the failing assertions and the scoreboard errors. Restore the original line afterwards.

## License

MIT, see [LICENSE](LICENSE).
