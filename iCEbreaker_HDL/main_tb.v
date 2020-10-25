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
	force template_tb.dut.pll_36mh.clock_out = clk_i;
	end


// ==== DUT ====
main dut(
	.pin_clk_i(clk_i),
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
localparam ADC_VAL = 16'h2FFF;
assign SA_ADC_Comp_i = adc_shreg_l <= ADC_VAL;
reg[15:0] adc_shreg_s;
reg[15:0] adc_shreg_l;

initial
	begin
	adc_shreg_s <= 0;
	adc_shreg_l <= 0;
	end

// Find rising edges of SCLK and LCLK
reg adc_sclk_old;
reg adc_lclk_old;
always @ (posedge clk_i) begin
	adc_sclk_old <= SA_ADC_SClk_o;
	adc_lclk_old <= SA_ADC_LClk_o;
	end

// Emulate Shift register
always @ (posedge clk_i) begin
	if(SA_ADC_SClk_o & ~adc_sclk_old) begin
		adc_shreg_s <= {SA_ADC_Ser_o,adc_shreg_s[15:1]};
		end
	if(SA_ADC_LClk_o & ~adc_lclk_old) begin
		adc_shreg_l <= adc_shreg_s;
		end
	end

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

