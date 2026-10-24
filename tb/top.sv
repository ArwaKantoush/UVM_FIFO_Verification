module top();

import uvm_pkg::*;
`include "uvm_macros.svh"

import FIFO_test_pkg::*;
import shared_pkg::*;

bit clk;
initial begin
  clk = 1;
  forever begin
    #5 clk = ~clk;
  end
end

FIFO_if FIFOif (clk);
FIFO DUT (
  .clk(clk),
  .rst_n(FIFOif.rst_n),
  .wr_en(FIFOif.wr_en),
  .rd_en(FIFOif.rd_en),
  .data_in(FIFOif.data_in),
  .data_out(FIFOif.data_out),
  .wr_ack(FIFOif.wr_ack),
  .overflow(FIFOif.overflow),
  .underflow(FIFOif.underflow),
  .full(FIFOif.full),
  .empty(FIFOif.empty),
  .almostfull(FIFOif.almostfull),
  .almostempty(FIFOif.almostempty)
);

initial begin
  uvm_config_db #(virtual FIFO_if)::set(null, "uvm_test_top", "FIFO_IF", FIFOif);
  run_test("FIFO_test");
end

bind FIFO FIFO_sva FIFO_sva_inst(
  .FIFO_if(top.FIFOif),
  .count(count),
  .wr_ptr(wr_ptr),
  .rd_ptr(rd_ptr)
);

endmodule
