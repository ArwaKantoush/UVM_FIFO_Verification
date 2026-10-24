package FIFO_reset_seq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import FIFO_seq_item_pkg::*;
    import shared_pkg::*;

    class FIFO_reset_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_reset_seq);
        FIFO_seq_item seq_item;

        function new (string name = "FIFO_reset_seq");
            super.new(name);
        endfunction

        task body;
            seq_item = FIFO_seq_item::type_id::create("seq_item");
            repeat(3) begin
                start_item(seq_item);
                seq_item.rst_n = 0;
                seq_item.wr_en = 0;
                seq_item.rd_en = 0;
                seq_item.data_in = 0;
                seq_item.data_out = 0;
                seq_item.wr_ack = 0;
                seq_item.overflow = 0;
                seq_item.underflow = 0;
                seq_item.full = 0;
                seq_item.empty = 0;
                seq_item.almostfull = 0;
                seq_item.almostempty = 0;
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
