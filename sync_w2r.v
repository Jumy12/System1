module sync_w2r #(parameter ADRRSIZE=3)
(
input wire rclk,
input wire rrst_n,
input wire [ADRRSIZE:0] wptr_gray,
output reg [ADRRSIZE:0] rq2_wptr
);

reg [ADRRSIZE:0] rq1_wptr;

always @(posedge rclk or negedge rrst_n)
  begin
	if(!rrst_n)
	 begin
	  rq1_wptr <= 'b0;
	  rq2_wptr <= 'b0;
	 end 
	else 
	 begin
	  rq1_wptr <= wptr_gray;
	  rq2_wptr <= rq1_wptr;
	 end 	 
  end 

endmodule   
