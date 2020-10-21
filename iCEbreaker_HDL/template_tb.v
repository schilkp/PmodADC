‘timescale 1ns / 1ps

module template_tb();

// ==== Applied Stimuli ====
reg clk_i, reset_ni;

// ==== Results ====
wire SA_ADC_SH_o;
wire SA_ADC_Ser_o;
wire SA_ADC_SClk_o;
wire SA_ADC_LClk_o;
wire SA_ADC_Comp_;
wire [13:0] SA_ADC_data_i;
wire SA_ADC_data_rdy_i;


// Handle simulation
parameter DURATION = 1000; // x timescale
‘define DUMPSTR(x) ‘" x.vcd‘"

initial begin
	$dumpfile(‘DUMPSTR(‘VCD_OUTPUT));
	$dumpvars(0 , template_tb ) ;
    #(DURATION) $display ("End of simulation");
	$finish ;
end

endmodule

