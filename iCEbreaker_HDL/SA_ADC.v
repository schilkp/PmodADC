module SA_ADC (
	input wire clk_i, // Clock in 
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

endmodule