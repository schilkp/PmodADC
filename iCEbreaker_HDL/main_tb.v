`timescale 1ns/1ps
module template_tb();

// ==== Applied Stimuli ====
reg clk_i, reset_ni;


// ==== FPGA IO ====
wire SA_ADC_SH_o;
wire SA_ADC_Ser_o;
wire SA_ADC_SClk_o;
wire SA_ADC_LClk_o;
wire SA_ADC_Comp_i;
wire [13:0] SA_ADC_data_o;
wire SA_ADC_data_rdy_o;

// ==== Results ====
reg [13:0] result;

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


// ==== DUT ====
main dut(
	.clk_i(clk_i),
	.reset_ni(reset_ni),
	.SA_ADC_SH_o(SA_ADC_SH_o),
	.SA_ADC_Ser_o(SA_ADC_Ser_o),
	.SA_ADC_SClk_o(SA_ADC_SClk_o),
	.SA_ADC_LClk_o(SA_ADC_LClk_o),
	.SA_ADC_Comp_i(SA_ADC_Comp_i),
	.SA_ADC_data_o(SA_ADC_data_o),
	.SA_ADC_data_rdy_o(SA_ADC_data_rdy_o)
);

// ==== Emulate ADC ====
assign SA_ADC_Comp_i = 0;


// ==== Handle simulation ====
parameter DURATION = 1000; //x timescale
`define DUMPSTR(x) `"x.vcd`"

initial begin
  $dumpfile(`DUMPSTR(`VCD_OUTPUT));
  $dumpvars(0, template_tb);
   #(DURATION) $display("End of simulation");
  $finish;
end	
	
endmodule

