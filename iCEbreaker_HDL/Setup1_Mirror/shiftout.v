module shiftout(
	input clk_i,
	input reset_ni,
	
	input wire [WIDTH-1:0] data_i,
	input wire data_rdy_i,
	
	output serial_o,
	output sclk_o,
	output lclk_o
);

localparam WIDTH = 16;

// Handle rising edge detection of data_rdy_i
reg data_rdy_old;
always @ (posedge clk_i, negedge reset_ni)
	begin
	if(~reset_ni)
		begin
		data_rdy_old <= 0;
		end
	else
		begin
		data_rdy_old <= data_rdy_i;
		end
	end

// Handle statemachine
reg [2:0] state;
localparam STATE_IDLE = 0;
localparam STATE_SHIFTOUT_SHFT = 1;
localparam STATE_SHIFTOUT_LTCH = 2;
localparam STATE_LATCHOUT = 3;

reg lclk;
assign lclk_o = lclk;

reg sclk;
assign sclk_o = sclk;

reg [WIDTH-1:0] data;
reg [5:0] shifout_count;

assign serial_o = data[WIDTH-1];

always @ (posedge clk_i, negedge reset_ni)
	begin
	if(~reset_ni)
		begin
		state <= STATE_IDLE;
		lclk <= 0;
		sclk <= 0;
		data <= 0;
		shifout_count <= 0;
		end
	else
		begin
			case(state)
				STATE_IDLE:
					begin
					lclk <= 0;
					sclk <= 0;
					shifout_count <= 0;
					// Begin new shiftout on rising edge of data_rdy_i
					if(data_rdy_i && ~data_rdy_old)
						begin
						data <= data_i;
						state <= STATE_SHIFTOUT_LTCH;
						end
					end
				STATE_SHIFTOUT_SHFT:
					begin
					sclk <= 0;
					data = data << 1;
					if(shifout_count == WIDTH)
						begin
						state <= STATE_LATCHOUT;
						end
					else 
						begin
						state <= STATE_SHIFTOUT_LTCH;
						end
					end
				STATE_SHIFTOUT_LTCH:
					begin
					sclk <= 1;
					state <= STATE_SHIFTOUT_SHFT;
					shifout_count <= shifout_count + 1;
					end
				STATE_LATCHOUT:
					begin
					lclk <= 1;
					state <= STATE_IDLE;
					end
				default: 
					begin
					state <= STATE_IDLE;
					lclk <= 0;
					sclk <= 0;
					data <= 0;
					shifout_count <= 0;
					end
			endcase
		end
	end

endmodule