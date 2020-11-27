module computer_interface(
	// System
	input clk_i,
	input reset_ni,
	
	// FTDI FT2232H Interface
	inout [0:7] data_io,
	input nRXF_i,
	input nTXE_i,
	output nRD_o,
	output nWR_o,
	
	// ADC Interface
	input [13:0] adc_data_i,
	input adc_data_rdy_i,
	
	// DAC Interface
	output reg [13:0] dac_data_o,
	output reg dac_data_rdy_o,
	
	// Status LEDs
	output led_txerr_o,
	output led_rxerr_o
);

reg [13:0] next_dac_data;

reg adc_data_rdy_old;
reg [13:0] adc_data;

wire tx_pckg_1 = {1'b1, adc_data_i[13:7]};
wire tx_pckg_2 = {1'b0, adc_data[6:0]};

reg fifo_tx_data_rdy;
reg [7:0] fifo_tx_data;
reg fifo_rx_poll;

wire fifo_busy;
wire fifo_tx_err;
wire fifo_rx_err;
wire [7:0] fifo_rx_data;
wire fifo_rx_data_rdy;
wire fifo_tx_ok;

fifo_interface fifo(
	// System
	.clk_i(clk_i),
	.reset_ni(reset_ni),
	
	// FTDI FT2232H Interface
	.data_io(data_io),
	.nRXF_i(nRXF_i),
	.nTXE_i(nTXE_i),
	.nRD_o(nRD_o),
	.nWR_o(nWR_o),
	
	// TX Interface
	.tx_data_rdy_i(fifo_tx_data_rdy),
	.tx_data_i(fifo_tx_data),
	.tx_err_o(fifo_tx_err),
	.tx_ok_o(fifo_tx_ok),
	
	// RX Interface
	.rx_poll_i(fifo_rx_poll),
	.rx_data_rdy_o(fifo_rx_data_rdy),
	.rx_data_o(fifo_rx_data),
	.rx_err_o(fifo_rx_err),
	
	// busy indicator
	.busy_o(fifo_busy)
);

reg [25:0] ledcnt_rxerr;
reg [25:0] ledcnt_txerr;
assign led_txerr_o = ledcnt_txerr != 0;
assign led_rxerr_o = ledcnt_rxerr != 0;
localparam LEDCNT_MAX = 7200000;

// Decrease counters without under-flowing
function [25:0] dec_cntr (input [25:0] value);
	begin
		if(value == 0) begin
			dec_cntr = value;
		end else begin
			dec_cntr = value-1;
		end
	end
endfunction

// Check if first received package is OK
function first_pckg_ok(input [7:0] pckg);
	begin
		first_pckg_ok = (pckg[7] == 1'b1);
	end
endfunction

// Check if second received package is OK
function second_pckg_ok(input [7:0] pckg);
	begin
		second_pckg_ok = (pckg[7] == 1'b0);
	end
endfunction

// State Machine
reg [2:0] state;

localparam STATE_IDLE = 0;
localparam STATE_TX1 =  1;
localparam STATE_TX2 =  2;
localparam STATE_RX1 =  3;
localparam STATE_RX2 =  4;

always @ (posedge clk_i) begin
	if(~reset_ni) begin
		adc_data_rdy_old <= 'b0;
		state <= STATE_IDLE;
		ledcnt_rxerr <= 'b0;
		ledcnt_txerr <= 'b0;
		adc_data <= 'b0;
		fifo_tx_data <= 'b0;
		fifo_tx_data_rdy <= 'b0;
		fifo_rx_poll <= 'b0;
		dac_data_rdy_o <= 'b0;
		next_dac_data <= 'b0;
		dac_data_o <= 'b0;
	end else begin
		adc_data_rdy_old <= adc_data_rdy_i;
		
		case(state) 
			STATE_IDLE: begin
				// Wait for rising rising edge on adc_data_rdy_i
				if(adc_data_rdy_i & ~adc_data_rdy_old) begin 
					// Start Transmission of first package
					state <= STATE_TX1;
					adc_data <= adc_data_i;
					fifo_tx_data <= {1'b1, adc_data_i[13:7]};
					fifo_tx_data_rdy <= 1;
					dac_data_rdy_o <= 1;
				end else begin
					// Keep waiting
					dac_data_rdy_o <= 0;
					state <= state;
					adc_data <= adc_data;
					fifo_tx_data <= fifo_tx_data;
					fifo_tx_data_rdy <= 0;
				end
				
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				fifo_rx_poll <= 0;
				next_dac_data <= next_dac_data;
				dac_data_o <= dac_data_o;
			end
			STATE_TX1: begin
				// Wait for first transmission to finish
				if(fifo_tx_ok) begin 
					// First package transmitted correctly.
					// Transmit second package.
					state <= STATE_TX2;
					ledcnt_txerr <= dec_cntr(ledcnt_txerr);
					fifo_tx_data <= {1'b0, adc_data[6:0]};
					fifo_tx_data_rdy <= 1;
					fifo_rx_poll <= 0;
				end else if (fifo_tx_err /*| ~fifo_busy*/) begin
					// First package transmitted incorrectly.
					// Skip second package and attempt to receive first package. 
					state <= STATE_RX1;
					ledcnt_txerr <= LEDCNT_MAX;
					fifo_tx_data <= fifo_tx_data;
					fifo_tx_data_rdy <= 0;
					fifo_rx_poll <= 1;
				end else begin
					// Keep waiting
					state <= state;
					ledcnt_txerr <= dec_cntr(ledcnt_txerr);
					fifo_tx_data <= fifo_tx_data;
					fifo_tx_data_rdy <= 0;
					fifo_rx_poll <= 0;
				end
				
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				adc_data <= adc_data;
				dac_data_rdy_o <= 0;
				next_dac_data <= next_dac_data;
				dac_data_o <= dac_data_o;
			end
			STATE_TX2: begin
				// Wait for second transmission to finish
				if(fifo_tx_ok | fifo_tx_err /*| ~fifo_busy*/) begin 
					// Second package transmission over.
					// Attempt to receive first package. 
					state <= STATE_RX1;
					fifo_rx_poll <= 1;
					if(~fifo_tx_ok) begin
						// Transmission failed.
						// Set Error LED
						ledcnt_txerr <= LEDCNT_MAX;
					end else begin
						ledcnt_txerr <= dec_cntr(ledcnt_txerr);
					end
				end else begin 
					// Keep waiting
					state <= state;
					ledcnt_txerr <= dec_cntr(ledcnt_txerr);
					fifo_rx_poll <= 0;
				end
				
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				adc_data <= adc_data;
				fifo_tx_data <= fifo_tx_data;
				fifo_tx_data_rdy <= 0;
				dac_data_rdy_o <= 0;
				next_dac_data <= next_dac_data;
				dac_data_o <= dac_data_o;
			end
			STATE_RX1: begin
				// Wait for first reception to finish
				if(fifo_rx_data_rdy | fifo_rx_err /*| ~fifo_busy*/) begin 
					// First package reception over
					if(fifo_rx_data_rdy & first_pckg_ok(fifo_rx_data)) begin
						// Successful, Receive second package.
						state <= STATE_RX2;
						ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
						fifo_rx_poll <= 1;
						next_dac_data <= (fifo_rx_data & 8'h7F) << 7; 
					end else begin
						// Failed, Stop reception
						state <= STATE_IDLE;
						ledcnt_rxerr <= LEDCNT_MAX;
						//ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
						fifo_rx_poll <= 0;
						next_dac_data <= 'b0;
					end
					
				end else begin 
					// Keep waiting
					state <= state;
					ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
					fifo_rx_poll <= 0;
					next_dac_data <= next_dac_data;
				end
				
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				adc_data <= adc_data;
				fifo_tx_data <= fifo_tx_data;
				fifo_tx_data_rdy <= 0;
				dac_data_rdy_o <= 0;
				dac_data_o <= dac_data_o;
			end
			STATE_RX2: begin
				// Wait for second reception to finish
				if(fifo_rx_data_rdy | fifo_rx_err /*| ~fifo_busy*/) begin 
					// Second package reception over
					state <= STATE_IDLE;
					if(fifo_rx_data_rdy & second_pckg_ok(fifo_rx_data)) begin
						// Successful
						// ledcnt_rxerr <= LEDCNT_MAX;
						ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
						dac_data_o <= next_dac_data | (fifo_rx_data & 8'h7F);
						next_dac_data <= 'b0;
					end else begin
						// Failed
						ledcnt_rxerr <= LEDCNT_MAX;
						//ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
						next_dac_data <= next_dac_data;
						dac_data_o <= dac_data_o;
					end
					
				end else begin 
					// Keep waiting
					state <= state;
					ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
					next_dac_data <= next_dac_data;
					dac_data_o <= dac_data_o;
				end
				
				dac_data_rdy_o <= 0;
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				adc_data <= adc_data;
				fifo_tx_data <= fifo_tx_data;
				fifo_tx_data_rdy <= 0;
				fifo_rx_poll <= 0;
			end
			default: begin
				adc_data_rdy_old <= 'b0;
				state <= STATE_IDLE;
				ledcnt_rxerr <= 'b0;
				ledcnt_txerr <= 'b0;
				adc_data <= 'b0;
				fifo_tx_data <= 'b0;
				fifo_tx_data_rdy <= 'b0;
				fifo_rx_poll <= 'b0;
				dac_data_rdy_o <= 'b0;
				next_dac_data <= 'b0;
				dac_data_o <= 'b0;
			end
		endcase
	end
end


endmodule