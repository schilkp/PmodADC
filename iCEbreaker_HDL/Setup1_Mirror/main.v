module main (
	input wire pin_clk_i, // Clock in 
	input wire reset_ni, // Reset in
	
	// ADC Interface
	output ADC_SH_o,
	output ADC_Ser_o,
	output ADC_SClk_o,
	output ADC_LClk_o,
	input ADC_Comp_i,
	output ADC_Comp_L_o,
	
	output DAC_Ser_o,
	output DAC_SClk_o,
	output DAC_LClk_o
	
	
	/*
		// Data Output
		output wire [13:0] SA_ADC_data_o,
		output wire SA_ADC_data_rdy_o
	*/
);

wire clk;
wire [13:0] data;
wire data_rdy;
assign ADC_Comp_L_o = 1'b0;


pll pll_36mh(
	.clock_in(pin_clk_i),
	.clock_out(clk),
	.locked()
);



SA_ADC sa_adc(
	.clk_i(clk),
	.reset_ni(reset_ni),
	.sh_o(ADC_SH_o),
	.ser_o(ADC_Ser_o),
	.sclk_o(ADC_SClk_o),
	.lclk_o(ADC_LClk_o),
	.comp_i(ADC_Comp_i),
	.data_o(data),
	.data_rdy_o(data_rdy)
);

shiftout dac_out(
	.clk_i(clk),
	.reset_ni(reset_ni),
	
	.data_i({2'b0, data}),
	.data_rdy_i(data_rdy),
	
	.serial_o(DAC_Ser_o),
	.sclk_o(DAC_SClk_o),
	.lclk_o(DAC_LClk_o)
);

endmodule