module main (
	input wire pin_clk_i, // Clock in 
	input wire reset_ni, // Reset in
	
	// ADC Interface
	output wire SA_ADC_SH_o,
	output wire SA_ADC_Ser_o,
	output wire SA_ADC_SClk_o,
	output wire SA_ADC_LClk_o,
	input wire SA_ADC_Comp_i,
	
	// Data Output
	output wire [13:0] SA_ADC_data_o,
	output wire SA_ADC_data_rdy_o
);

wire clk;

pll pll_36mh(
	.clock_in(pin_clk_i),
	.clock_out(clk),
	.locked()
);

SA_ADC sa_adc(
	.clk_i(clk),
	.reset_ni(reset_ni),
	.sh_o(SA_ADC_SH_o),
	.ser_o(SA_ADC_Ser_o),
	.sclk_o(SA_ADC_SClk_o),
	.lclk_o(SA_ADC_LClk_o),
	.comp_i(SA_ADC_Comp_i),
	.data_o(SA_ADC_data_o),
	.data_rdy_o(SA_ADC_data_rdy_o)
);

endmodule