module FIFO_sva #(parameter FIFO_DEPTH = 8, parameter max_fifo_addr = $clog2(FIFO_DEPTH)) (
	FIFO_if FIFO_if,
    input logic [max_fifo_addr:0] count,
    input logic [max_fifo_addr-1:0] wr_ptr,
    input logic [max_fifo_addr-1:0] rd_ptr
);

property rst_n_propert;
	@(posedge FIFO_if.clk) (FIFO_if.rst_n == 0) |-> count == 0 && rd_ptr == 0 && wr_ptr == 0;
endproperty
assert property (rst_n_propert);
cover property (rst_n_propert);

always_comb begin
    if (FIFO_if.rst_n) begin
        a_full: assert final (FIFO_if.full == (count == FIFO_DEPTH));
        a_empty: assert final (FIFO_if.empty == (count == 0));
        a_afull: assert final (FIFO_if.almostfull == (count == FIFO_DEPTH-1));
        a_aempty: assert final (FIFO_if.almostempty == (count == 1));
    end
end

cover property (@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.full);
cover property (@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.empty);
cover property (@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.almostfull);
cover property (@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) FIFO_if.almostempty);

property overflow_propert;
	@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) (FIFO_if.full & FIFO_if.wr_en) |=> FIFO_if.overflow;
endproperty
assert property (overflow_propert);
cover property (overflow_propert);

property underflow_propert;
	@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) (FIFO_if.rd_en && count == 0) |=> FIFO_if.underflow;
endproperty
assert property (underflow_propert);
cover property (underflow_propert);

property wr_ack_propert;
	@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) (FIFO_if.wr_en && count < FIFO_DEPTH) |=> FIFO_if.wr_ack;
endproperty
assert property (wr_ack_propert);
cover property (wr_ack_propert);

property wr_ptr_wrap_propert;
    @(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n)
        (wr_ptr == FIFO_DEPTH-1 && FIFO_if.wr_en && !FIFO_if.full) |=> (wr_ptr == 0);
endproperty
assert property (wr_ptr_wrap_propert);
cover property (wr_ptr_wrap_propert);

property rd_ptr_wrap_propert;
    @(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n)
        (rd_ptr == FIFO_DEPTH-1 && FIFO_if.rd_en && !FIFO_if.empty) |=> (rd_ptr == 0);
endproperty
assert property (rd_ptr_wrap_propert);
cover property (rd_ptr_wrap_propert);

property Pointer_threshold_propert;
	@(posedge FIFO_if.clk) disable iff (!FIFO_if.rst_n) (rd_ptr < FIFO_DEPTH && wr_ptr < FIFO_DEPTH && count <= FIFO_DEPTH);
endproperty
assert property (Pointer_threshold_propert);
cover property (Pointer_threshold_propert);

endmodule
