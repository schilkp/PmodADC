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
	
	// TX Interface
	input tx_data_rdy_i,
	input [0:7] tx_data_i,
	output reg tx_err_o,
	output reg tx_ok_o,
	
	// RX Interface
	input rx_poll_i,
	output reg rx_data_rdy_o,
	output reg [0:7] rx_data_o,
	output reg rx_err_o,
	
	// busy indicator
	output reg busy_o
);

// data_rdy/rx_poll rising edge detection
reg tx_data_rdy_old;
reg rx_poll_old;

// State machine
reg [2:0] state;
localparam STATE_IDLE = 0;
localparam STATE_TX = 1;
localparam STATE_RX = 3;

reg [1:0] tx_state;
localparam TX_ST1 = 0;
localparam TX_ST2 = 1;
localparam TX_ST3 = 2;
localparam TX_ST4 = 3;

reg [1:0] rx_state;
localparam RX_ST1 = 0;
localparam RX_ST2 = 1;
localparam RX_ST3 = 2;
localparam RX_ST4 = 3;

// Data
reg [7:0] tx_data;

// IO
reg bus_oe;
assign data_io = bus_oe ? tx_data : 8'bz;

always @ (posedge clk_i) begin
	if(~reset_ni) begin
		tx_data_rdy_old <= 'b0;
		rx_err_o <= 1'b0;
		tx_err_o <= 1'b0;
		tx_data <= 0;
		state <= STATE_IDLE;
		bus_oe <= 0;
		nWR_o <= 1;
		nRD_o <= 1;
		rx_data_o <= 0;
		rx_data_rdy_o <= 0;
		rx_poll_old <= 0;
		tx_state <= TX_ST1;
		rx_state <= RX_ST1;
		busy_o <= 0;
		tx_ok_o <= 0;
	end else begin
		tx_data_rdy_old <= tx_data_rdy_i;
		rx_poll_old <= rx_poll_i;
		
		case(state)
			STATE_IDLE: begin
				nWR_o <= 1;
				rx_data_o <= rx_data_o;
				rx_data_rdy_o <= 0;
				tx_state <= TX_ST1;
				rx_state <= RX_ST1;
				tx_ok_o <= 0;
				
				// Start TX on tx_data_rdy posedge
				if(~tx_data_rdy_old & tx_data_rdy_i) begin
					rx_err_o <= 1'b0;
					tx_data <= tx_data_i;
					nRD_o <= 1;
					// See if the FT2232H is ready to transmit:
					if(~nTXE_i) begin
						// Ready - Start transmission
						tx_err_o <= 1'b0;
						state <= STATE_TX;
						bus_oe <= 1;
						busy_o <= 1;
					end else begin
						// Not Ready - indicate error
						tx_err_o <= 1'b1;
						state <= STATE_IDLE;
						bus_oe <= 0;
						busy_o <= 0;
					end
				end else begin
					tx_data <= tx_data;
					bus_oe <= 0;
					tx_err_o <= 1'b0;
					// Start RX on rising edge of rx_poll_i
					if(~rx_poll_old & rx_poll_i) begin
							if(~nRXF_i) begin
							// Data in FIFO - Receive
							rx_err_o <= 1'b0;
							state <= STATE_RX;
							nRD_o <= 0; // Receive
							busy_o <= 1;
						end else begin
							// FIFO empty - Indicate error and skip transmission
							rx_err_o <= 1'b1;
							state <= STATE_IDLE;
							nRD_o <= 1;
							busy_o <= 0;
						end
					end else begin
						state <= STATE_IDLE;
						rx_err_o <= 1'b0;
						nRD_o <= 1;
						busy_o <= 0;
					end
				end
			end
			
			STATE_TX: begin
				tx_data <= tx_data;
				tx_err_o <= 1'b0;
				rx_err_o <= 1'b0;
				nRD_o <= 1;
				rx_data_o <= rx_data_o;
				rx_data_rdy_o <= 0;
				rx_state <= RX_ST1;
				busy_o <= 1;
				
				case(tx_state) 
					TX_ST1: begin
						nWR_o <= 0; // TX
						state <= STATE_TX;
						bus_oe <= 1;
						tx_state <= TX_ST2;
						tx_ok_o <= 0;
					end
					
					TX_ST2: begin
						nWR_o <= 0; // TX
						state <= STATE_TX;
						bus_oe <= 0;
						tx_state <= TX_ST3;
						tx_ok_o <= 0;
					end
					
					TX_ST3: begin
						nWR_o <= 1;
						state <= STATE_TX;
						bus_oe <= 0;
						tx_state <= TX_ST4;
						tx_ok_o <= 0;
					end
					
					TX_ST4: begin
						nWR_o <= 1;
						bus_oe <= 0;
						state <= STATE_IDLE;
						tx_ok_o <= 1;
					end
					
					default: begin
						tx_state <= TX_ST1; // Recover
						state <= STATE_IDLE;
					end
				endcase
			end
			
			STATE_RX: begin
				tx_data <= tx_data;
				tx_err_o <= 1'b0;
				rx_err_o <= 1'b0;
				bus_oe <= 0;
				nWR_o <= 1;
				tx_state <= TX_ST1;
				busy_o <= 1;
				tx_ok_o <= 0;
				
				case(rx_state) 
					RX_ST1: begin
						rx_state <= RX_ST2;
						state <= STATE_RX;
						nRD_o <= 0; // Keep Receiving
						rx_data_o <= data_io; // Store Data
						rx_data_rdy_o = 0;
					end
					
					RX_ST2: begin
						rx_state <= RX_ST3;
						state <= STATE_RX;
						nRD_o <= 1;
						rx_data_o <= rx_data_o;
						rx_data_rdy_o = 0;
					end
					
					RX_ST3: begin
						rx_state <= RX_ST4;
						state <= STATE_RX;
						nRD_o <= 1;
						rx_data_o <= rx_data_o;
						rx_data_rdy_o = 0;
					end
					
					RX_ST4: begin
						rx_state <= RX_ST1;
						state <= STATE_IDLE;
						nRD_o <= 1;
						rx_data_o <= rx_data_o;
						rx_data_rdy_o <= 1; // indicate data received.
					end
					
					default: begin
						rx_state <= RX_ST1; // Recover
						state <= STATE_IDLE;
					end
				endcase
				
			end
			
			default: begin
				tx_data_rdy_old <= 'b0;
				rx_err_o <= 1'b0;
				tx_err_o <= 1'b0;
				tx_data <= 0;
				state <= STATE_IDLE;
				bus_oe <= 0;
				nWR_o <= 1;
				nRD_o <= 1;
				rx_data_o <= 0;
				rx_data_rdy_o <= 0;
				rx_poll_old <= 0;
				tx_state <= TX_ST1;
				rx_state <= RX_ST1;
				tx_ok_o <= 0;
			end
		endcase
	end
end


endmodule