module RST_SYNC #(parameter NUM_STAGES = 2)
(
input wire RST,
input wire CLK,
output wire SYNC_RST
);

reg [NUM_STAGES-1:0] sync_flops;

always @(posedge CLK or negedge RST)
  begin
	if(!RST)
	  begin
	    sync_flops <= 'b0;
	  end
	else
	  begin
		sync_flops <= {sync_flops[NUM_STAGES-2:0] , 1'b1}; //shift 1 to propagate through the chain
	  end 
end 

assign SYNC_RST = sync_flops[NUM_STAGES-1];

endmodule

	  