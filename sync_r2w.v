module sync_r2w #(parameter ADRRSIZE=3)
(
input wire wclk,
input wire wrst_n,
input wire [ADRRSIZE:0] rptr_gray,
output reg [ADRRSIZE:0] wq2_rptr
);

reg [ADRRSIZE:0] wq1_rptr;

always @(posedge wclk or negedge wrst_n)
  begin
	if(!wrst_n)
	 begin
	  wq1_rptr <= 'b0;
	  wq2_rptr <= 'b0;
	 end 
	else 
	 begin
	  wq1_rptr <= rptr_gray;
	  wq2_rptr <= wq1_rptr;
	 end 		
  end
  
endmodule
  