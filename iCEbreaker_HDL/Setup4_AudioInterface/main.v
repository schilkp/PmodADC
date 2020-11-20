module main(
	// System
	input pin_clk_i,
	input reset_ni,

	// FIFO interface
	inout fifo_d0_io,
	inout fifo_d1_io,
	inout fifo_d2_io,
	inout fifo_d3_io,
	inout fifo_d4_io,
	inout fifo_d5_io,
	inout fifo_d6_io,
	inout fifo_d7_io,
	
	input fifo_nRXF_i,
    input fifo_nTXE_i,
    output fifo_nRD_o,
    output fifo_nWD_o,
	
	// LEDs
	output led_txerr_o,
	output led_rxerr_o,
	
    // ADC Interface
	output ADC_SH_o,
	output ADC_Ser_o,
	output ADC_SClk_o,
	output ADC_LClk_o,
	input ADC_Comp_i,
	output ADC_Comp_L_o,
	
	// DAC Interface
	output DAC_Ser_o,
	output DAC_SClk_o,
	output DAC_LClk_o
);

assign ADC_Comp_L_o = 1'b0;

wire clk;
pll pll_36mh(
	.clock_in(pin_clk_i),
	.clock_out(clk),
	.locked()
);

wire [13:0] adc_data;
wire adc_data_rdy;
wire [13:0] dac_data;
wire dac_data_rdy;
wire led_txerrinv_o;
wire led_rxerrinv_o;
assign led_txerr_o = ~led_txerrinv_o;
assign led_rxerr_o = ~led_rxerrinv_o;

computer_interface adc_dac_interface(
	// System
	.clk_i(clk),
	.reset_ni(reset_ni),
	
	// FTDI FT2232H Interface
	.data_io({fifo_d7_io, fifo_d6_io, fifo_d5_io ,fifo_d4_io, fifo_d3_io, fifo_d2_io, fifo_d1_io, fifo_d0_io}),
	.nRXF_i(fifo_nRXF_i),
	.nTXE_i(fifo_nTXE_i),
	.nRD_o(fifo_nRD_o),
	.nWR_o(fifo_nWD_o),
	
	// ADC Interface
	.adc_data_i(adc_data),
	.adc_data_rdy_i(adc_data_rdy),
	
	// DAC Interface
	.dac_data_o(dac_data),
	.dac_data_rdy_o(dac_data_rdy),
	
	// Status LEDs
	.led_txerr_o(led_txerrinv_o),
	.led_rxerr_o(led_rxerrinv_o)
);

SA_ADC sa_adc(
	.clk_i(clk),
	.reset_ni(reset_ni),
	
	.sh_o(ADC_SH_o),
	.ser_o(ADC_Ser_o),
	.sclk_o(ADC_SClk_o),
	.lclk_o(ADC_LClk_o),
	.comp_i(ADC_Comp_i),
	
	.data_o(adc_data),
	.data_rdy_o(adc_data_rdy)
);

shiftout dac_out(
	.clk_i(clk),
	.reset_ni(reset_ni),
	
	.data_i({2'b0, dac_data}),
	.data_rdy_i(dac_data_rdy),
	
	.serial_o(DAC_Ser_o),
	.sclk_o(DAC_SClk_o),
	.lclk_o(DAC_LClk_o)
);
endmodule