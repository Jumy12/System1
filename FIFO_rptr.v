module FIFO_rptr #(parameter ADRRSIZE=3)
(
input wire rinc,
input wire rclk,
input wire rrst_n,
input wire  [ADRRSIZE:0]   rq2_wptr,
output wire [ADRRSIZE-1:0] raddr,
output reg  [ADRRSIZE:0]   rptr_gray,
output reg rempty
);

reg [ADRRSIZE:0]  rptr_bin;
wire EMPTY;
assign EMPTY = (rptr_gray == rq2_wptr);
assign raddr = rptr_bin[ADRRSIZE-1:0];

always @(posedge rclk or negedge rrst_n)
   begin
   if(!rrst_n)
     begin
	    rptr_bin  <= 'b0;
		
	 end 	
   else if (rinc && !rempty)
	 begin
	    rptr_bin  <= rptr_bin +1;
			    
	 end 
   end 

always @(*)
   begin
    if(EMPTY)
	rempty = 'b1;
	else 
	rempty = 'b0;
 end 

 always@(*)
 begin
    rptr_gray = (rptr_bin >> 1)^rptr_bin;
 end
 
endmodule 