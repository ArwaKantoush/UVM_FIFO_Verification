package FIFO_scoreboard_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import FIFO_seq_item_pkg::*;
    import shared_pkg::*;

    class FIFO_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_scoreboard)

        uvm_analysis_export #(FIFO_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
        FIFO_seq_item seq_item_sb;

        logic [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

        logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
        logic [max_fifo_addr:0] count;

        logic [FIFO_WIDTH-1:0] data_out_ref;
        logic wr_ack_ref, overflow_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

        logic rd_valid;

        int error_count = 0;
        int correct_count = 0;

        function new(string name = "FIFO_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
            sb_fifo.get(seq_item_sb);
            ref_model(seq_item_sb);
            if (seq_item_sb.data_out !== data_out_ref || seq_item_sb.full !== full_ref || seq_item_sb.empty !== empty_ref || seq_item_sb.almostfull !== almostfull_ref || seq_item_sb.almostempty !== almostempty_ref || seq_item_sb.overflow !== overflow_ref || seq_item_sb.underflow !== underflow_ref || seq_item_sb.wr_ack !== wr_ack_ref) begin
                `uvm_error("run_phase", $sformatf("Comparison failed, Transaction received by the DUT:%s while the reference data_out:0b%0b wr_ack:0b%0b overflow:0b%0b underflow:0b%0b full:0b%0b empty:0b%0b almostfull:0b%0b almostempty:0b%0b", seq_item_sb.convert2string(), data_out_ref, wr_ack_ref, overflow_ref, underflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref));
                error_count++;
            end
            else begin
                `uvm_info("run_phase", $sformatf("Correct FIFO out: %s ", seq_item_sb.convert2string()), UVM_HIGH);
                correct_count++;
            end
            end
        endtask

        task ref_model(FIFO_seq_item seq_item_chk);

            if (!seq_item_chk.rst_n) begin
                wr_ptr = 0;
                rd_ptr = 0;
                wr_ack_ref = 0;
		        overflow_ref = 0;
                underflow_ref = 0;
                count = 0;
                rd_valid = 0;

            end
            else begin
                wr_ack_ref = 0;
		        overflow_ref = 0;
                underflow_ref = 0;
                rd_valid = 0;

                if (seq_item_chk.wr_en && count < FIFO_DEPTH) begin
                    mem[wr_ptr] = seq_item_chk.data_in;
                    wr_ack_ref = 1;
                    wr_ptr = wr_ptr + 1;
                    overflow_ref = 0;
                end
                else if (seq_item_chk.wr_en && count == FIFO_DEPTH) begin
                    wr_ack_ref = 0;
                    if (full_ref && seq_item_chk.wr_en)
                        overflow_ref = 1;
                    else
                        overflow_ref = 0;
                end

                if (seq_item_chk.rd_en && count != 0) begin
                    data_out_ref = mem[rd_ptr];
                    rd_ptr = rd_ptr + 1;
                    rd_valid = 1;
                end
                else if (seq_item_chk.rd_en && count == 0) begin
                    underflow_ref = 1;
                end

                if ({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b11) begin
                    if (!full_ref && !empty_ref) begin
                        count = count;
                    end
                    else if (!full_ref) begin
                        count = count + 1;
                    end
                    else begin
                        count = count - 1;
                    end
                end
                else if	( ({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b10) && !full_ref)
                    count = count + 1;
                else if ( ({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b01) && !empty_ref)
                    count = count - 1;
            end

            full_ref = (count == FIFO_DEPTH)? 1 : 0;
            empty_ref = (count == 0)? 1 : 0;
            almostfull_ref = (count == FIFO_DEPTH-1)? 1 : 0;
            almostempty_ref = (count == 1)? 1 : 0;
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM);
        endfunction

    endclass
endpackage
