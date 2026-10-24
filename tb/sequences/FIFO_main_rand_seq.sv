package FIFO_main_rand_seq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import FIFO_seq_item_pkg::*;

    class FIFO_main_rand_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_main_rand_seq)
        function new(string name = "FIFO_main_rand_seq");
            super.new(name);
        endfunction

        task body;
            FIFO_seq_item seq_item;
            repeat (20000) begin
                seq_item = FIFO_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage
