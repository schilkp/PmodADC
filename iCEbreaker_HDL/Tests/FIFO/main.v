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
	output led_rxerr_o
);

wire clk;
reg [15:0] counter;
reg [7:0] data_counter;
reg tx_data_rdy;

pll pll_36mh(
	.clock_in(pin_clk_i),
	.clock_out(clk),
	.locked()
);


fifo_interface fifo(
	.clk_i(clk),
	.reset_ni(reset_ni),

	.data_io({fifo_d7_io, fifo_d6_io, fifo_d5_io ,fifo_d4_io, fifo_d3_io, fifo_d2_io, fifo_d1_io, fifo_d0_io}),
	.nRXF_i(fifo_nRXF_i),
	.nTXE_i(fifo_nTXE_i),
	.nRD_o(fifo_nRD_o),
	.nWR_o(fifo_nWD_o),

	.tx_data_rdy_i(tx_data_rdy),
	.tx_data_i(data_counter),
	.rx_data_rdy_o(),
	.rx_data_o(),

	.tx_err_o(),
	.rx_err_o(),
	.tx_err_led_o(led_txerr_o),
	.rx_err_led_o(led_rxerr_o)
);

localparam COUNTER_MAX = 877;

 always @ (posedge clk) begin
	if(~reset_ni) begin
		counter <= 'b0;
		data_counter <= 'b0;
		tx_data_rdy <= 'b0;
	end else begin
		if(counter == COUNTER_MAX) begin
			counter <= 0;
			if(data_counter == "}") begin
				data_counter <= "1";
			end else begin	
				data_counter <= data_counter + 1;
			end
			tx_data_rdy <= 1;
		end else begin
			counter <= counter + 1;
			data_counter <= data_counter;
			tx_data_rdy <= 0;
		end
	end
end


endmodule