module FIFO_wptr #(parameter ADRRSIZE=3)
(
input wire winc,
input wire wclk,
input wire wrst_n,
input wire [ADRRSIZE:0] wq2_rptr,  //read ptr after synch.
output reg wfull,
output wire [ADRRSIZE-1:0] waddr,
output reg [ADRRSIZE:0] wptr_gray
);

reg [ADRRSIZE:0] wptr_bin;
wire FULL;
assign FULL = ( wptr_gray[3] != wq2_rptr[3] && wptr_gray[2] != wq2_rptr[2] && wptr_gray[1:0] == wq2_rptr[1:0]);
assign waddr = wptr_bin[ADRRSIZE-1:0];   //MSB of ptr to distinguish bet full and empty

always @(posedge wclk or negedge wrst_n)
  begin
    if (!wrst_n)
	  begin
	   wptr_bin  <= 'b0;
	   
	   end
	else if (winc && !wfull)
	  begin
		wptr_bin  <= wptr_bin + 1;
	  end 
  end 

always @(*)
  begin
   if(FULL)
    wfull = 'b1;
	else
	wfull = 'b0;
   end

always @(*)
begin
wptr_gray = (wptr_bin >> 1) ^ wptr_bin;
end 

endmodule    
