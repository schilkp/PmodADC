`timescale 1ns/1ps
module template_tb();

// ==== Applied Stimuli ====
reg clk_i, reset_ni;
reg [15:0] data;
reg data_rdy;

// ==== FPGA IO ====
wire shiftout_ser;
wire shiftout_sclk;
wire shiftout_rclk;


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
	//force template_tb.dut.u_pll.clock_out = clk_i;
	end

// ==== Generate data and data_rdy
initial
	begin
		data <= 16'hFE55;
		data_rdy <= 0;
	end

always 
	begin
	#700 data = data+1;
		data_rdy = 1;
	#200 data_rdy = 0;
	end

// ==== DUT ====
shiftout dut(
	.clk_i(clk_i),
	.reset_ni(reset_ni),
	
	.data_i(data),
	.data_rdy_i(data_rdy),
	
	.serial_o(shiftout_ser),
	.sclk_o(sclk_o),
	.lclk_o(lclk_o)
);

// ==== Handle simulation ====
parameter DURATION = 10000; //x timescale
`define DUMPSTR(x) `"x.vcd`"

initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, template_tb);
   #(DURATION) $display("End of simulation");
  $finish;
end	
	
endmodule

