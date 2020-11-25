`timescale 1ns/1ps
module template_tb();

// ==== Applied Stimuli ====
reg clk_i, reset_ni;
reg [7:0] data_io_set;
reg data_io_oe;

// ==== FPGA IO ====
wire ADC_Ser_o;
wire ADC_SClk_o;
wire ADC_LClk_o;
wire ADC_Comp_i;

wire DAC_Ser_o;
wire DAC_SClk_o;
wire DAC_LClk_o;

wire [7:0] fifo_data_io;
assign fifo_data_io = data_io_oe ? data_io_set : 8'bz;

// ==== Results ====
reg [13:0] result;




// ==== DUT ====
main dut(
	// System
	.pin_clk_i(clk_i),
	.reset_ni(reset_ni),
	
	// ADC Interface
	.ADC_SH_o(),
	.ADC_Ser_o(ADC_Ser_o),
	.ADC_SClk_o(ADC_SClk_o),
	.ADC_LClk_o(ADC_LClk_o),
	.ADC_Comp_i(ADC_Comp_i),
	
	// DAC Interface
	.DAC_Ser_o(DAC_Ser_o),
	.DAC_SClk_o(DAC_SClk_o),
	.DAC_LClk_o(DAC_LClk_o),

	// FIFO Interface
	.fifo_d0_io(fifo_data_io[0]),
	.fifo_d1_io(fifo_data_io[1]),
	.fifo_d2_io(fifo_data_io[2]),
	.fifo_d3_io(fifo_data_io[3]),
	.fifo_d4_io(fifo_data_io[4]),
	.fifo_d5_io(fifo_data_io[5]),
	.fifo_d6_io(fifo_data_io[6]),
	.fifo_d7_io(fifo_data_io[7]),
	
	.fifo_nRXF_i(1'b0),
    .fifo_nTXE_i(1'b0),
    .fifo_nRD_o(),
    .fifo_nWD_o(),
	
	// LEDs
	.led_txerr_o(),
	.led_rxerr_o()
);

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

// ==== Emulate Response from FIFO ====
initial
	begin
		data_io_oe = 1'b0;
		data_io_set = 8'b0;
		#17800 data_io_oe = 1'b1;
			  data_io_set = 8'hAF;
		#80   data_io_set = 8'h7F;
		#100   data_io_oe = 1'b0;
	end

// ==== Emulate ADC ====
localparam ADC_VAL = 16'h2A52;
assign ADC_Comp_i = adc_shreg_l <= ADC_VAL;
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
	adc_sclk_old <= ADC_SClk_o;
	adc_lclk_old <= ADC_LClk_o;
	end

// Emulate Shift register
always @ (posedge clk_i) begin
	if(ADC_SClk_o & ~adc_sclk_old) begin
		adc_shreg_s <= {adc_shreg_s[14:0],ADC_Ser_o};
		end
	if(ADC_LClk_o & ~adc_lclk_old) begin
		adc_shreg_l <= adc_shreg_s;
		end
	end

// ==== Emulate DAC ====
reg[15:0] dac_shreg_s;
reg[15:0] dac_shreg_l;

initial
	begin
	dac_shreg_s <= 0;
	dac_shreg_l <= 0;
	end
	
// Find rising edges of SCLK and LCLK
reg dac_sclk_old;
reg dac_lclk_old;
always @ (posedge clk_i) begin
	dac_sclk_old <= DAC_SClk_o;
	dac_lclk_old <= DAC_LClk_o;
	end
	
// Emulate Shift register
always @ (posedge clk_i) begin
	if(DAC_SClk_o & ~dac_sclk_old) begin
		dac_shreg_s <= {dac_shreg_s[14:0],DAC_Ser_o};
		end
	if(DAC_LClk_o & ~dac_lclk_old) begin
		dac_shreg_l <= dac_shreg_s;
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

