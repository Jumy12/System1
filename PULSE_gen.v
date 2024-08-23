module PULSE_gen(
input wire RST,
input wire CLK,
input wire LVL_SIG,
output wire PULSE_SIG
);


reg SIG_FF;
reg PULSE_FF;

always @(posedge CLK or negedge RST)
  begin
    if(!RST)
	  begin
	    SIG_FF <= 'b0;
		PULSE_FF <= 'b0;
	  end
    else 
	  begin
	    SIG_FF <= LVL_SIG;
		PULSE_FF <= SIG_FF;
	  end
   end

assign  PULSE_SIG = (!PULSE_FF && SIG_FF);

endmodule
