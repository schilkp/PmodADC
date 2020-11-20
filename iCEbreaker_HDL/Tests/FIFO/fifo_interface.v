 module fifo_interface(
	// System
	input clk_i,
	input reset_ni,
	
	// FTDI FT2232H Interface
	inout [0:7] data_io,
	input nRXF_i,
	input nTXE_i,
	output reg nRD_o,
	output reg nWR_o,
	
	// Data Interface
	input tx_data_rdy_i,
	input [0:7] tx_data_i,
	output reg rx_data_rdy_o,
	output reg [0:7] rx_data_o,
	
	// Error Indicators
	output reg tx_err_o,
	output reg rx_err_o,
	output tx_err_led_o,
	output rx_err_led_o
);

// Data ready rising edge detection
reg tx_data_rdy_old;

// State machine
reg [2:0] state;
localparam STATE_IDLE = 0;
localparam STATE_TX_1 = 1;
localparam STATE_TX_2 = 2;
localparam STATE_TX_3 = 3;
localparam STATE_COOLDOWN = 4;
localparam STATE_RX_1 = 5;
localparam STATE_RX_2 = 6;

// Error LED
reg [25:0] ledcnt_rxerr;
reg [25:0] ledcnt_txerr;
assign tx_err_led_o = ledcnt_txerr != 0;
assign rx_err_led_o = ledcnt_rxerr != 0;
localparam LEDCNT_MAX = 36000000;

// Data
reg [7:0] tx_data;

// IO
reg bus_oe;
assign data_io = bus_oe ? tx_data : 8'bz;

// Function to decrease counters without under-flowing
function [25:0] dec_cntr (input [25:0] value);
	begin
		if(value == 0) begin
			dec_cntr = value;
		end else begin
			dec_cntr = value-1;
		end
	end
endfunction

always @ (posedge clk_i) begin
	if(~reset_ni) begin
		tx_data_rdy_old <= 'b0;
		rx_err_o <= 1'b0;
		tx_err_o <= 1'b0;
		tx_data <= 0;
		ledcnt_rxerr <= 0;
		ledcnt_txerr <= 0;
		state <= STATE_IDLE;
		bus_oe <= 0;
		nWR_o <= 1;
		nRD_o <= 1;
		rx_data_o <= 0;
		rx_data_rdy_o <= 0;
	end else begin
		tx_data_rdy_old <= tx_data_rdy_i;
		case(state)
			STATE_IDLE: begin
				rx_err_o <= 1'b0;
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				nWR_o <= 1;
				nRD_o <= 1;
				rx_data_o <= rx_data_o;
				rx_data_rdy_o <= 0;
				// Detect new data by looking for rising edge on data_rdy
				if(~tx_data_rdy_old & tx_data_rdy_i) begin 
					tx_data <= tx_data_i;
					// See if the FT2232H is ready to transmit:
					if(~nTXE_i) begin
						// Ready - Start transmission
						tx_err_o <= 1'b0;
						ledcnt_txerr <= dec_cntr(ledcnt_txerr);
						state <= STATE_TX_1;
						bus_oe <= 1;
					end else begin
						// Not Ready - indicate error
						tx_err_o <= 1'b1;
						ledcnt_txerr <= LEDCNT_MAX;
						state <= STATE_COOLDOWN;
						bus_oe <= 0;
					end
				end else begin
					tx_data <= tx_data;
					ledcnt_txerr <= dec_cntr(ledcnt_txerr);
					state <= STATE_IDLE;
					bus_oe <= 0;
				end
			end
			
			STATE_TX_1: begin
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				tx_data <= tx_data;
				tx_err_o <= 1'b0;
				rx_err_o <= 1'b0;
				state <= STATE_TX_2;
				bus_oe <= 1;
				nWR_o <= 0; // Transmit
				nRD_o <= 1;
				rx_data_o <= rx_data_o;
				rx_data_rdy_o <= 0;
			end
			
			STATE_TX_2: begin
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				tx_data <= tx_data;
				tx_err_o <= 1'b0;
				rx_err_o <= 1'b0;
				state <= STATE_TX_3;
				bus_oe <= 0;
				nWR_o <= 0; // Min. 30ns Transmit
				nRD_o <= 1;
				rx_data_o <= rx_data_o;
				rx_data_rdy_o <= 0;
			end
			
			STATE_TX_3: begin
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				tx_data <= tx_data;
				tx_err_o <= 1'b0;
				rx_err_o <= 1'b0;
				state <= STATE_COOLDOWN;
				bus_oe <= 0;
				nWR_o <= 1;
				nRD_o <= 1;
				rx_data_o <= rx_data_o;
				rx_data_rdy_o <= 0;
			end
			
			STATE_COOLDOWN: begin
				tx_data <= tx_data;
				tx_err_o <= 1'b0;
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				bus_oe <= 0;
				nWR_o <= 1;
				rx_data_o <= rx_data_o;
				rx_data_rdy_o <= 0;
				
				// See if there is data to be received
				if(~nRXF_i) begin
					// Data in FIFO - Receive
					rx_err_o <= 1'b0;
					ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
					state <= STATE_RX_1;
					nRD_o <= 0; // Receive
				end else begin
					// FIFO empty - Indicate error and skip transmission
					rx_err_o <= 1'b1;
					ledcnt_rxerr <= LEDCNT_MAX;
					state <= STATE_IDLE;
					nRD_o <= 1;
				end
			end
			
			STATE_RX_1: begin
				tx_data <= tx_data;
				tx_err_o <= 1'b0;
				rx_err_o <= 1'b0;
				ledcnt_rxerr <= dec_cntr(ledcnt_rxerr);
				ledcnt_txerr <= dec_cntr(ledcnt_txerr);
				state <= STATE_IDLE;
				bus_oe <= 0;
				nWR_o <= 1;
				nRD_o <= 0; // Keep Receiving
				rx_data_o <= data_io; // Store Data
				rx_data_rdy_o <= 1; // indicate data received.
			end
			
			default: begin
				tx_data_rdy_old <= 'b0;
				rx_err_o <= 1'b0;
				tx_err_o <= 1'b0;
				tx_data <= 0;
				ledcnt_rxerr <= 0;
				ledcnt_txerr <= 0;
				state <= STATE_IDLE;
				bus_oe <= 0;
				nWR_o <= 1;
				nRD_o <= 1;
				rx_data_o <= 0;
				rx_data_rdy_o <= 0;
			end
		endcase
	end
end


endmodule