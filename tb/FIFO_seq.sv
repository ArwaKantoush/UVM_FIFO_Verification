package FIFO_seq_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import FIFO_seq_item_pkg::*;

    class FIFO_seq extends uvm_sequencer #(FIFO_seq_item);
        `uvm_component_utils(FIFO_seq)

        function new (string name = "FIFO_seq", uvm_component parent = null);
            super.new(name, parent);
        endfunction
    endclass
endpackage
