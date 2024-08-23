module ASYC_FIFO  #(parameter DATA_WIDTH =8 , parameter ADRRSIZE=3)
(
input wire wclk,
input wire wrst_n,
input wire winc,
input wire rclk,
input wire rrst_n,
input wire rinc,
input wire [DATA_WIDTH-1:0] wdata,
output wire wfull,
output wire rempty,
output wire [DATA_WIDTH-1:0] rdata
);

//internal connections
wire [ADRRSIZE-1:0] waddr;
wire [ADRRSIZE-1:0] raddr;
wire [ADRRSIZE:0]   wq2_rptr;
wire [ADRRSIZE:0]   wptr_gray;
wire [ADRRSIZE:0]   rq2_wptr;
wire [ADRRSIZE:0]   rptr_gray;


FIFO_MEM #(.DATA_WIDTH(DATA_WIDTH) , .ADRRSIZE(ADRRSIZE)) FM0(
.wdata(wdata),
.winc(winc),
.waddr(waddr),
.raddr(raddr),
.rdata(rdata),
.wfull(wfull),
.wclk(wclk)
);

FIFO_wptr #(.ADRRSIZE(ADRRSIZE)) FW (
.wfull(wfull),
.wclk(wclk),
.winc(winc),
.wrst_n(wrst_n),
.wptr_gray(wptr_gray),
.wq2_rptr(wq2_rptr),
.waddr(waddr)
);

FIFO_rptr #(.ADRRSIZE(ADRRSIZE)) FR (
.rclk(rclk),
.rrst_n(rrst_n),
.rinc(rinc),
.rempty(rempty),
.rptr_gray(rptr_gray),
.rq2_wptr(rq2_wptr),
.raddr(raddr)
);

sync_r2w #(.ADRRSIZE(ADRRSIZE)) DFr2w (
.wclk(wclk),
.wrst_n(wrst_n),
.rptr_gray(rptr_gray),
.wq2_rptr(wq2_rptr)
);

sync_w2r #(.ADRRSIZE(ADRRSIZE)) DFw2r ( 
.rclk(rclk),
.rrst_n(rrst_n),
.wptr_gray(wptr_gray),
.rq2_wptr(rq2_wptr)
);

endmodule 
