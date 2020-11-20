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
reg [7:0] data;
reg tx_data_rdy;

pll pll_36mh(
	.clock_in(pin_clk_i),
	.clock_out(clk),
	.locked()
);

wire rx_rdy;
wire [7:0] rx_data;
reg rx_poll;

fifo_interface fifo(
	.clk_i(clk),
	.reset_ni(reset_ni),

	.data_io({fifo_d7_io, fifo_d6_io, fifo_d5_io ,fifo_d4_io, fifo_d3_io, fifo_d2_io, fifo_d1_io, fifo_d0_io}),
	.nRXF_i(fifo_nRXF_i),
	.nTXE_i(fifo_nTXE_i),
	.nRD_o(fifo_nRD_o),
	.nWR_o(fifo_nWD_o),

	.tx_data_rdy_i(tx_data_rdy),
	.tx_data_i(data),
	.tx_err_o(),
	
	.rx_poll_i(rx_poll),
	.rx_data_rdy_o(rx_rdy),
	.rx_data_o(rx_data),
	.rx_err_o(),
	
	.busy_o()
	
);

localparam COUNTER_MAX = 877;
localparam COUNTER_HALF = 438;


always @ (posedge clk) begin
	if(~reset_ni) begin
		counter <= 'b0;
		data <= "P";
		tx_data_rdy <= 'b0;
		rx_poll <= 'b0;
	end else begin

		if(counter == COUNTER_MAX) begin
			counter <= 0;
			tx_data_rdy <= 1;
			if(data == "}") begin
				data <= "1";
			end else begin	
				data <= data + 1;
			end
		end else begin
			counter <= counter + 1;
			tx_data_rdy <= 0;
			data <= data;
		end 
		
		if(counter == COUNTER_HALF) begin
			rx_poll <= 'b1;
		end else begin
			rx_poll <= 'b0;
		end
	end
end


endmodule