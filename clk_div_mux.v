module clk_div_mux #(parameter DATA_WIDTH = 8)
(
input wire [5:0] sel,
output reg [DATA_WIDTH-1:0] div_ratio
);

always @(*)
  begin
    case(sel)
	    6'd32:begin
		div_ratio = 'd1;
		end 
		6'd16:begin
		div_ratio = 'd2;
		end
		6'd8 :begin  
		div_ratio = 'd4;
		end 
		default:begin
		div_ratio = 'd1;
		end 
    endcase

end 

endmodule	