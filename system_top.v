module System_TOP #( parameter DATA_WIDTH = 8,
							   OUT_WIDTH = DATA_WIDTH*2,
						       Addr_size=4
						                 )
(
input  wire REF_CLK,
input  wire RST,
input  wire UART_CLK,
input  wire RX_IN,
output wire TX_OUT,
output wire parity_error,
output wire framing_error
);

wire SYNC_REF_RST;
wire SYNC_UART_RST;

wire [DATA_WIDTH-1:0] UART_RX_OUT;
wire UART_RX_VALID;
wire [DATA_WIDTH-1:0] RX_P_DATA_sync;
wire RX_D_VLD_sync;
wire TX_D_VLD;
wire BUSY_PULSE_sync;
wire [DATA_WIDTH-1:0] TX_P_Data;
wire FIFO_FULL;
wire TX_D_VLD_sync;
wire [DATA_WIDTH-1:0] TX_P_Data_sync;
wire TX_BUSY;
wire TX_CLK;
wire RX_CLK;

wire clk_div_en;
wire [DATA_WIDTH-1:0] Div_Ratio;
wire [DATA_WIDTH-1:0] Div_Ratio_RX;

wire [DATA_WIDTH-1:0] UART_config;

wire [OUT_WIDTH-1:0] ALU_OUT;
wire ALU_OUT_VALID;
wire ALU_EN;
wire [3:0]ALU_FUN;
wire [Addr_size-1:0] Address;
wire GATE_EN;
wire ALU_CLK;

wire WrEN;
wire RdEn;
wire [DATA_WIDTH-1:0] RF_RdData;
wire RdData_VALID;
wire [DATA_WIDTH-1:0] RF_WrData;
wire [DATA_WIDTH-1:0] Operand_A;
wire [DATA_WIDTH-1:0] Operand_B;


//RST synchronizers
RST_SYNC #(.NUM_STAGES(2)) U0_RST_SYNC(
.RST(RST),
.CLK(REF_CLK),
.SYNC_RST(SYNC_REF_RST)
);

RST_SYNC #(.NUM_STAGES(2)) U1_RST_SYNC(
.RST(RST),
.CLK(UART_CLK),
.SYNC_RST(SYNC_UART_RST)
);										 

//Data synchronizers
DATA_sync #(.NUM_STAGES(2),.bus_width(8)) U0_DATA_SYNC(
.unsync_bus(UART_RX_OUT),
.bus_en(UART_RX_VALID),
.CLK(REF_CLK),
.RST(RST),
.sync_bus(RX_P_DATA_sync),
.enable_pulse_d(RX_D_VLD_sync)
);

//FIFO
ASYC_FIFO #(.DATA_WIDTH(DATA_WIDTH), .ADRRSIZE(3)) U0_FIFO(
.wclk(REF_CLK),
.wrst_n(SYNC_REF_RST),
.winc(TX_D_VLD),
.rclk(TX_CLK),
.rrst_n(SYNC_UART_RST),
.rinc(BUSY_PULSE_sync),
.wdata(TX_P_Data),
.wfull(FIFO_FULL),
.rempty(TX_D_VLD_sync),
.rdata(TX_P_Data_sync)
);

//PULSE generator
PULSE_gen U0_PG(
.RST(SYNC_UART_RST),
.CLK(TX_CLK),
.LVL_SIG(TX_BUSY),
.PULSE_SIG(BUSY_PULSE_sync)
);

//CLK DIVIDER for TX
ClkDiv #(.RATIO_WD(8)) U0_CLKDIV(
.i_ref_clk(UART_CLK),
.i_rst(SYNC_UART_RST),
.i_clk_en(clk_div_en),
.i_div_ratio(Div_Ratio),
.o_div_clk(TX_CLK)
);

//custom mux
clk_div_mux #(.DATA_WIDTH(DATA_WIDTH)) U0_mux(
.sel(UART_config[7:2]),
.div_ratio(Div_Ratio_RX)
);

//CLK DIVIDER for RX
ClkDiv #(.RATIO_WD(8)) U1_CLKDIV(
.i_ref_clk(UART_CLK),
.i_rst(SYNC_UART_RST),
.i_clk_en(clk_div_en),
.i_div_ratio(Div_Ratio_RX),
.o_div_clk(RX_CLK)
);

//UART_TOP
UART  U0_UART (
.RST(SYNC_UART_RST),
.TX_CLK(TX_CLK),
.RX_CLK(RX_CLK),
.parity_enable(UART_config[0]),
.parity_type(UART_config[1]),
.Prescale(UART_config[7:2]),
.RX_IN_S(RX_IN),
.RX_OUT_P(UART_RX_OUT),                      
.RX_OUT_V(UART_RX_VALID),                      
.TX_IN_P(TX_P_Data_sync), 
.TX_IN_V(!TX_D_VLD_sync), 
.TX_OUT_S(TX_OUT),
.TX_OUT_V(TX_BUSY),
.parity_error(parity_error),
.framing_error(framing_error)                  
);

//system control
sys_ctrl #(.DATA_WIDTH(DATA_WIDTH), .Addr_size(Addr_size), .OUT_WIDTH(OUT_WIDTH)) U0_s_ctrl(
.ALU_OUT(ALU_OUT),
.ALU_OUT_VALID(ALU_OUT_VALID),
.RX_P_Data_sync(RX_P_DATA_sync),
.RX_D_VLD_sync(RX_D_VLD_sync),
.RF_RdData(RF_RdData),
.RdData_VALID(RdData_VALID),
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.FIFO_FULL(FIFO_FULL),
.ALU_EN(ALU_EN),
.ALU_FUN(ALU_FUN),
.Address(Address),
.WrEN(WrEN),
.RdEn(RdEn),
.RF_WrData(RF_WrData),
.TX_P_Data(TX_P_Data),
.TX_D_VLD(TX_D_VLD),
.GATE_EN(GATE_EN),
.clk_div_en(clk_div_en)
);

//RegFile
RegFile U0_RegFile (
.CLK(REF_CLK),
.RST(SYNC_REF_RST),
.WrEn(WrEN),
.RdEn(RdEn),
.Address(Address),
.WrData(RF_WrData),
.RdData(RF_RdData),
.RdData_VLD(RdData_VALID),
.REG0(Operand_A),
.REG1(Operand_B),
.REG2(UART_config),
.REG3(Div_Ratio)
);

//ALU
ALU U0_ALU (
.CLK(ALU_CLK),
.RST(SYNC_REF_RST),  
.A(Operand_A), 
.B(Operand_B),
.EN(ALU_EN),
.ALU_FUN(ALU_FUN),
.ALU_OUT(ALU_OUT),
.OUT_VALID(ALU_OUT_VALID)
);

//Gated_clk
CLK_GATE U0_CLK_GATE (
.CLK_EN(GATE_EN),
.CLK(REF_CLK),
.GATED_CLK(ALU_CLK)
);


endmodule