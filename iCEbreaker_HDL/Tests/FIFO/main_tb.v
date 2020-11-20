`timescale 1ns/1ps
module template_tb();

// ==== Applied Stimuli ====
reg clk_i, reset_ni;


// ==== Generate Clock and Reset ====
initial
	begin
		reset_ni = 1'b0;
	#15	reset_ni = 1'b1;
	end
	
initial
	clk_i = 1'b0;
	
always
	begin
	#10 clk_i = ~clk_i;
	force template_tb.dut.pll_36mh.clock_out = clk_i;
	end


// ==== DUT ====
main dut(
    .pin_clk_i(1'b0),
    .reset_ni(reset_ni),

    .fifo_d0_io(),
    .fifo_d1_io(),
    .fifo_d2_io(),
    .fifo_d3_io(),
    .fifo_d4_io(),
    .fifo_d5_io(),
    .fifo_d6_io(),
    .fifo_d7_io(),

    .fifo_nRXF_i(1'b0),
    .fifo_nTXE_i(1'b0),
    .fifo_nRD_o(),
    .fifo_nWD_o(),

    .led_txerr_o(),
    .led_rxerr_o()
);

// ==== Handle simulation ====
parameter DURATION = 100000; //x timescale
`define DUMPSTR(x) `"x.vcd`"

initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, template_tb);
   #(DURATION) $display("End of simulation");
  $finish;
end	
	
endmodule

