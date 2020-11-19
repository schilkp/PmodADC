module SA_ADC (
	input wire clk_i, // Clock in 
	input wire reset_ni, // Reset in
	
	// ADC Interface
	output wire sh_o,
	output wire ser_o,
	output wire sclk_o,
	output wire lclk_o,
	input wire comp_i,
	
	// Data Output
	output wire [13:0] data_o,
	output wire data_rdy_o
);

// State machine state
reg [3:0] state;

localparam STATE_SAMPLE = 0;
localparam STATE_SAMPLE_LENGTH = 200;

localparam STATE_SAMPLE_SETTLE = 1;
localparam STATE_SAMPLE_SETTLE_LENGTH = 30;

localparam STATE_DAC_SET = 2;
localparam STATE_DAC_SET_LENGTH = 45;

reg [11:0] state_time_count;
reg [4:0] current_bit;

// Sample and hold interface
reg sh;
assign sh_o = sh;

// DAC interface
reg [13:0] dac_data_determined;
reg [13:0] dac_data_test;
wire [15:0] dac_data;
assign dac_data = {2'b0, dac_data_determined | dac_data_test};

reg dac_data_rdy;

shiftout dac_interface(
	.clk_i(clk_i),
	.reset_ni(reset_ni),
	.data_i(dac_data),
	.data_rdy_i(dac_data_rdy),
	.serial_o(ser_o),
	.sclk_o(sclk_o),
	.lclk_o(lclk_o)
);

// Module outputs
reg dataout_rdy;
assign data_rdy_o = dataout_rdy;

reg [13:0] dataout;
assign data_o = dataout;

// Handle Statemachine
always @ (posedge clk_i, negedge reset_ni) begin
	if(~reset_ni) begin
		state <= STATE_SAMPLE;
		sh <= 0;
		dac_data_determined <= 0;
		dac_data_test <= 0;
		dac_data_rdy <= 0;
		dataout_rdy <= 0;
		dataout <= 0;
		state_time_count <= STATE_SAMPLE_LENGTH;
		current_bit <= 0;
	end else begin
		case(state)
		
		
			STATE_SAMPLE: begin
				sh <= 1;
				dataout_rdy <= 0;
				dac_data_rdy <= 0;
				dac_data_test <= 0;
				dataout <= dataout;
				dac_data_determined  <= 0;
				
				current_bit <= 0;
				
				if(state_time_count == 0) begin
					state <= STATE_SAMPLE_SETTLE;
					state_time_count <= STATE_SAMPLE_SETTLE_LENGTH;
				end else begin
					state <= state;
					state_time_count <= state_time_count - 1;
				end
			end
			
			
			STATE_SAMPLE_SETTLE: begin
				sh <= 0;
				dataout_rdy <= 0;
				dac_data_rdy <= 0;
				dac_data_test <= dac_data_test;
				dataout <= dataout;
				dac_data_determined  <= dac_data_determined;
				current_bit <= current_bit;
				
				if(state_time_count == 0) begin
					state <= STATE_DAC_SET;
					state_time_count <= STATE_DAC_SET_LENGTH;
				end else begin
					state <= state;
					state_time_count <= state_time_count - 1;
				end
			end
			
			
			STATE_DAC_SET: begin
				
				sh <= 0;
				
				if(state_time_count == STATE_DAC_SET_LENGTH) begin
					// If we just entered this state, output the current value on the dac
					dac_data_test <= (14'h2000 >> current_bit);
					dac_data_rdy <= 1;
				end else begin
					dac_data_test <= dac_data_test;
					dac_data_rdy <= 0;
				end
				
				if(state_time_count == 0) begin
					
					
					dac_data_determined = dac_data_determined | (comp_i << (13-current_bit));
					if(current_bit == 13) begin
						current_bit = 0;
						state <= STATE_SAMPLE;
						state_time_count <= STATE_SAMPLE_LENGTH;
						dataout_rdy <= 1;
						dataout <= {dac_data_determined[13:1],comp_i};
					end else begin
						current_bit = current_bit + 1;
						dataout <= dataout;
						state <= STATE_DAC_SET;
						state_time_count <= STATE_DAC_SET_LENGTH;
						dataout_rdy <= 0;
					end
				end else begin
					dataout <= dataout;
					dataout_rdy <= 0;
					state <= state;
					dac_data_determined <= dac_data_determined;
					current_bit <= current_bit;
					state_time_count <= state_time_count - 1;
				end
			end
			
			default: begin
				state <= STATE_SAMPLE;
				sh <= 0;
				dac_data_determined <= 0;
				dac_data_test <= 0;
				dac_data_rdy <= 0;
				dataout_rdy <= 0;
				dataout <= 0;
				state_time_count <= STATE_SAMPLE_LENGTH;
				current_bit <= 0;
			end
			
			
		endcase
	end
end


endmodule
