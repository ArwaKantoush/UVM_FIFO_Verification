interface FIFO_if #(parameter FIFO_WIDTH = 16, parameter FIFO_DEPTH = 8) (clk);
input bit clk;
logic rst_n, wr_en, rd_en;
logic [FIFO_WIDTH-1:0] data_in;
logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;
endinterface : FIFO_if
