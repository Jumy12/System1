module DATA_sync #(parameter bus_width = 8 , parameter NUM_STAGES = 2)
(
input wire [bus_width-1:0] unsync_bus,
input wire bus_en,
input wire CLK,
input wire RST,
output reg [bus_width-1:0] sync_bus,
output reg enable_pulse_d
);

reg first_flop;
reg sync_flop;
reg enable_flop;
wire enable_pulse;
wire [bus_width-1:0] sync_bus_m;


//double flop synch
always @(posedge CLK or negedge RST)
  begin
	if(!RST)
	 begin
	    first_flop <= 'b0;
		sync_flop <= 'b0;
	end
  else 
     begin
		first_flop <= bus_en;
		sync_flop <= first_flop;
     end 
  end

always @(posedge CLK or negedge RST)
  begin
	if(!RST)
	    begin  
         enable_flop <= 'b0;
		 end
	else
		 enable_flop <= sync_flop;
	end
	
assign enable_pulse = !enable_flop && sync_flop;

always @(posedge CLK or negedge RST)
  begin
	if(!RST)
	    begin  
		enable_pulse_d <= 'b0;
		end
	else
		enable_pulse_d <= enable_pulse;
	end

assign sync_bus_m = enable_pulse ? unsync_bus : sync_bus ;

always @(posedge CLK or negedge RST)
  begin
	if(!RST)
	    begin  	
		sync_bus <= 'b0;
		end
	else
         sync_bus <= sync_bus_m;
   end
   
endmodule   
	