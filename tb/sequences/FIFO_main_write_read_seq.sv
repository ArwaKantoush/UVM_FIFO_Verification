package FIFO_main_write_read_seq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import FIFO_seq_item_pkg::*;
    import shared_pkg::*;

    class FIFO_main_write_read_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_main_write_read_seq);
        FIFO_seq_item seq_item;

        function new (string name = "FIFO_main_write_read_seq");
            super.new(name);
        endfunction

        task body;
            seq_item = FIFO_seq_item::type_id::create("seq_item");
            repeat(10000) begin
                start_item(seq_item);
                assert(seq_item.randomize() with { wr_en == 1; rd_en == 1; });
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
