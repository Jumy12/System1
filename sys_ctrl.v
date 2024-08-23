module sys_ctrl #( parameter DATA_WIDTH = 8,
							 OUT_WIDTH = DATA_WIDTH*2,
						     Addr_size=4
						                 )
(
input wire [OUT_WIDTH-1:0] ALU_OUT,
input wire ALU_OUT_VALID,
input wire [DATA_WIDTH-1:0] RX_P_Data_sync,
input wire RX_D_VLD_sync,
input wire [DATA_WIDTH-1:0] RF_RdData,
input wire RdData_VALID,
input wire CLK,
input wire RST,
input wire FIFO_FULL,
output reg ALU_EN,
output reg [3:0]           ALU_FUN,
output reg [Addr_size-1:0] Address,
output reg WrEN,
output reg RdEn,
output reg [DATA_WIDTH-1:0] RF_WrData,
output reg [DATA_WIDTH-1:0] TX_P_Data,
output reg TX_D_VLD,
output reg GATE_EN,
output reg clk_div_en
);

//to handle 2bytes sent by alu

reg [OUT_WIDTH-1:0] alu_reg;

reg [7:0] Address_reg;	 
reg RF_ADDR_SAVE;
reg ALU_OUT_SAVE;


//states
localparam  [3:0] IDLE = 4'b0000,
				  RF_Wr_addr = 4'b0001,
				  RF_Wr_DATA = 4'b0011,
			      RF_Rd_addr = 4'b0110,
				  FIFO_write_RF = 4'b0100,
				  operand_A = 4'b1000,
				  operand_B = 4'b1001,
				  ALUFUN = 4'b1100,
				  ALU_STORE = 4'b1110,
				  FIFO_write_ALU1 = 4'b1111,
				  FIFO_write_ALU2 = 4'b1101;

 
reg         [3:0]      current_state , 
                       next_state    ;
 
always @(posedge CLK or negedge RST)
 begin
   if(!RST)
   current_state <= IDLE;
   else
   current_state <= next_state;
   end
   


//state_transitions
always@(*)
 begin
	ALU_EN     = 'b0;
	ALU_FUN    = 'b0;
	Address    = 'b0;
	WrEN       = 'b0;
	RdEn	   = 'b0;
	RF_WrData  = 'b0;
	TX_P_Data  = 'b0;
	TX_D_VLD   = 'b0;
	clk_div_en = 'b1;
	GATE_EN    = 'b0;
	RF_ADDR_SAVE =1'b0;
	ALU_OUT_SAVE= 1'b0;
	
	
	
	case(current_state)
	IDLE: begin
	ALU_EN     = 'b0;
	ALU_FUN    = 'b0;
	Address    = 'b0;
	WrEN       = 'b0;
	RdEn	   = 'b0;
	RF_WrData  = 'b0;
	clk_div_en = 'b1;
	GATE_EN    = 'b0;
	
	  if(RX_D_VLD_sync)
	    begin 
		case (RX_P_Data_sync)
	    'hAA:begin
		next_state = RF_Wr_addr;
		end
		'hBB:begin    
		next_state = RF_Rd_addr;
		end
		'hCC:begin   
		next_state = operand_A;
		end
		'hDD:begin   
		next_state = ALUFUN;
		end
		default:begin 
		next_state = IDLE;
		end
		endcase
	  end
	  else 
	    next_state = IDLE;
	end 
	
	RF_Wr_addr:begin
	 if(RX_D_VLD_sync)
	    begin 
	  RF_ADDR_SAVE= 'b1;
	  next_state = RF_Wr_DATA;
	  end
	 else
	  begin
      RF_ADDR_SAVE= 'b0;	 
	   next_state = RF_Wr_addr;	
	   end
	end 
	
	RF_Wr_DATA:begin
	 if(RX_D_VLD_sync)
	   begin 
	  WrEN =1'b1; 
	  RF_WrData= RX_P_Data_sync;
	  Address = Address_reg[Addr_size-1:0];
	  next_state= IDLE;
	  end 
	  else 
	    begin
	   WrEN =1'b0; 
	   RF_WrData= RX_P_Data_sync;
	   Address = Address_reg[Addr_size-1:0];
	   next_state = RF_Wr_DATA;
	   end
    end 
	 
	RF_Rd_addr:begin
	if(RX_D_VLD_sync)
	   begin 
	  RdEn =1'b1; 
	  Address=RX_P_Data_sync[Addr_size-1:0];
	  next_state= FIFO_write_RF;
	   end
	 else 
	  begin
	  RdEn =1'b0;
	  next_state = RF_Rd_addr;  
	  end
	end
	
	FIFO_write_RF:begin
	 if	(RdData_VALID && !FIFO_FULL)
	  begin
		TX_P_Data  = RF_RdData;
		TX_D_VLD   = 1'b1;
		next_state = IDLE ;
	  end 
     else 
	   begin
	    TX_D_VLD   = 1'b0;
        next_state = FIFO_write_RF;
		end
    end
	
    operand_A:begin
	if(RX_D_VLD_sync)
	 begin
	 WrEN       = 1'b1;
	 RF_WrData  = RX_P_Data_sync; 
     Address    = 'b00;
	 next_state = operand_B;
	 end
	else
	begin
	 WrEN       = 1'b0;
	 Address    = 'b00;
     next_state = operand_A;
   end	 
	end
	
	operand_B:begin
	 GATE_EN = 1'b1; //
	if(RX_D_VLD_sync)
	 begin
	 WrEN    = 1'b1;
	 RF_WrData  = RX_P_Data_sync; 
     Address    = 'b01;
	 next_state = ALUFUN;
	 end
	else
	begin
	 WrEN    = 1'b0;
	 Address = 'b01;
     next_state = operand_B;	
	end  
	end
	 
	ALUFUN:begin
	GATE_EN    = 1'b1;
	if(RX_D_VLD_sync)
	 begin 
	 ALU_EN     = 1'b1;
     ALU_FUN    = RX_P_Data_sync[3:0];
	 next_state = ALU_STORE;
     end
	else 
	begin
	 ALU_EN     = 1'b0;
	 ALU_FUN    = RX_P_Data_sync[3:0];
	 next_state = ALUFUN;
	end
	end
	
	ALU_STORE:begin
	GATE_EN = 1'b1;
	if(ALU_OUT_VALID)
	begin
	ALU_OUT_SAVE =1'b1;
	next_state = FIFO_write_ALU1;
	end
	else
	begin
	ALU_OUT_SAVE = 1'b0;
	next_state= ALU_STORE;
	end 
	end
	
	
	FIFO_write_ALU1:begin
	GATE_EN = 1'b1;
	 if(!FIFO_FULL)
	  begin
		TX_P_Data = alu_reg[7:0];
		TX_D_VLD   = 1'b1;
		next_state = FIFO_write_ALU2;
	  end
     else
	 begin
		TX_D_VLD   = 1'b0;
        next_state = FIFO_write_ALU1;
	end 
	end

	FIFO_write_ALU2:begin
	GATE_EN = 1'b1;
	 if(!FIFO_FULL)
	  begin
		TX_P_Data = alu_reg[15:8];
		TX_D_VLD   = 1'b1;
		next_state = IDLE ;
		
	  end
     else
	 begin
	    TX_D_VLD   = 1'b0;
        next_state = FIFO_write_ALU2;
	end 
	end
	
	default:begin
	next_state = IDLE;
	ALU_EN     = 'b0;
	ALU_FUN    = 'b0;
	Address    = 'b0;
	WrEN       = 'b0;
	RdEn	   = 'b0;
	RF_WrData  = 'b0;
	TX_P_Data  = 'b0;
	TX_D_VLD   = 'b0;
	clk_div_en = 'b1;
	GATE_EN    = 'b0;
	ALU_OUT_SAVE= 1'b0;
	RF_ADDR_SAVE =1'b0;
	
	  end 
	  
	endcase 
end


always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    Address_reg <= 8'b0 ;
   end
  else
   begin
    if (RF_ADDR_SAVE)
	 begin	
      Address_reg <= RX_P_Data_sync ;
	 end 
   end
 end
 
always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    alu_reg <= 'b0 ;
   end
  else
   begin
    if (ALU_OUT_SAVE)
	 begin	
      alu_reg <= ALU_OUT ;
	 end 
   end
 end 
 

endmodule 

	
	

  	