package FIFO_coverage_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import FIFO_seq_item_pkg::*;
    import shared_pkg::*;

    class FIFO_coverage extends uvm_component;
        `uvm_component_utils(FIFO_coverage)
        uvm_analysis_export #(FIFO_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
        FIFO_seq_item seq_item_cov;

        bit full_pre, empty_pre, almostfull_pre, almostempty_pre;

        covergroup FIFO_coverage_cg;
            cp_wr_en: coverpoint seq_item_cov.wr_en {
                bins wr_en_0 = {0};
                bins wr_en_1 = {1};
            }
            cp_rd_en: coverpoint seq_item_cov.rd_en {
                bins rd_en_0 = {0};
                bins rd_en_1 = {1};
            }
            cp_full_pre: coverpoint full_pre {
                bins full_0 = {0};
                bins full_1 = {1};
            }
            cp_empty_pre: coverpoint empty_pre {
                bins empty_0 = {0};
                bins empty_1 = {1};
            }
            cp_overflow: coverpoint seq_item_cov.overflow {
                bins overflow_0 = {0};
                bins overflow_1 = {1};
            }
            cp_underflow: coverpoint seq_item_cov.underflow {
                bins underflow_0 = {0};
                bins underflow_1 = {1};
            }
            cp_almostfull: coverpoint seq_item_cov.almostfull {
                bins almostfull_0 = {0};
                bins almostfull_1 = {1};
            }
            cp_almostempty: coverpoint seq_item_cov.almostempty {
                bins almostempty_0 = {0};
                bins almostempty_1 = {1};
            }
            cp_wr_ack: coverpoint seq_item_cov.wr_ack {
                bins wr_ack_0 = {0};
                bins wr_ack_1 = {1};
            }

            //  Cross: cx_wr_rd_full
            cx_wr_rd_full: cross cp_wr_en, cp_rd_en, cp_full_pre iff(seq_item_cov.rst_n);
            //  Cross: cx_wr_rd_empty
            cx_wr_rd_empty: cross cp_wr_en, cp_rd_en, cp_empty_pre iff(seq_item_cov.rst_n);
            //  Cross: cx_wr_rd_overflow
            cx_wr_rd_overflow: cross cp_wr_en, cp_rd_en, cp_overflow iff(seq_item_cov.rst_n) {
                ignore_bins wr_rd_overflow_0 = binsof (cp_wr_en.wr_en_0) && binsof (cp_overflow.overflow_1);
            }
            //  Cross: cx_wr_rd_underflow
            cx_wr_rd_underflow: cross cp_wr_en, cp_rd_en, cp_underflow iff(seq_item_cov.rst_n) {
                ignore_bins wr_rd_underflow_0 = binsof(cp_rd_en.rd_en_0) && binsof (cp_underflow.underflow_1);
            }
            //  Cross: cx_wr_rd_almostfull
            cx_wr_rd_almostfull: cross cp_wr_en, cp_rd_en, cp_almostfull iff(seq_item_cov.rst_n);
            //  Cross: cx_wr_rd_almostempty
            cx_wr_rd_almostempty: cross cp_wr_en, cp_rd_en, cp_almostempty iff(seq_item_cov.rst_n);
            //  Cross: cx_wr_rd_wr_ack
            cx_wr_rd_wr_ack: cross cp_wr_en, cp_rd_en, cp_wr_ack iff(seq_item_cov.rst_n) {
                ignore_bins wr_rd_wr_ack_0 = binsof(cp_wr_en.wr_en_0) && binsof (cp_wr_ack.wr_ack_1);
            }
        endgroup

        function new(string name = "FIFO_coverage", uvm_component parent = null);
            super.new(name, parent);
            FIFO_coverage_cg = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                FIFO_coverage_cg.sample();
                full_pre = seq_item_cov.full;
                empty_pre = seq_item_cov.empty;
                almostfull_pre = seq_item_cov.almostfull;
                almostempty_pre = seq_item_cov.almostempty;
            end
        endtask

    endclass
endpackage
