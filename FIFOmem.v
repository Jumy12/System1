module FIFO_MEM   #(parameter DATA_WIDTH =8 , parameter ADRRSIZE=3)
(
input wire wfull,
input wire winc,
input wire wclk,
input wire [ADRRSIZE-1:0] waddr,
input wire [DATA_WIDTH-1:0] wdata,
input wire [ADRRSIZE-1:0] raddr,
output wire [DATA_WIDTH-1:0] rdata
);


localparam DEPTH = 1 << ADRRSIZE; 

//define memory array
reg[DATA_WIDTH-1:0] mem[DEPTH-1:0];  //2^3 locations with 8-bit width

//read data
assign rdata = mem[raddr];


//write data
always @(posedge wclk)
  begin
    if(winc && !wfull)
	 begin
	  mem[waddr] <= wdata;
	 end
  end 
endmodule   

  