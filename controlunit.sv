//Control Unit
module controlunit(
	input logic [6:0] op,
	input logic rst,
	output logic [1:0] ALUop,  
	output logic ALUsrc,
	output logic MtoR,
	output logic regwrite,
	output logic memread,
	output logic memwrite,
	output logic branch
);

always_comb
begin
	if(rst)
	begin
		ALUop = 2'b00;
		ALUsrc = 1'b0;
		MtoR = 1'b0;
		regwrite = 1'b0;
		memread = 1'b0;
		memwrite = 1'b0;
		branch = 1'b0;
	end
	else
	begin
		case(op)
        7'b0110011://few R types -> add,sub,slt,sltu,sll,xor,srl,sra,or,and
		begin
             ALUop = 2'b10;
			 ALUsrc = 1'b0;
			 MtoR = 1'b0;
			 regwrite = 1'b1;
			 memread = 1'b0;
			 memwrite = 1'b0;
			 branch = 1'b0;
		end
        7'b1100011://SB types -> beq,bne
		begin
             ALUop = 2'b01;
			 ALUsrc = 1'b0;
			 MtoR = 1'bx;
			 regwrite = 1'b0;
			 memread = 1'b0;
			 memwrite = 1'b0;
			 branch = 1'b1;
		end
        7'b0000011:// -> lb,lh,lw,ld,lbu,lhu,lwu
		begin
             ALUop = 2'b00;
			 ALUsrc = 1'b1;
			 MtoR = 1'b1;
			 regwrite = 1'b1;
			 memread = 1'b1;
			 memwrite = 1'b0;
			 branch = 1'b0;
		end
        7'b0100011://->sd,sh,sw,sd
		begin
             ALUop = 2'b00; 
			 ALUsrc = 1'b1;
			 MtoR = 1'bx;
			 regwrite = 1'b0;
			 memread = 1'b0;
			 memwrite = 1'b1;
			 branch = 1'b0;
		end
		7'b0010011://->addi,slli,srai,ori,andi..
		begin
			 ALUop = 2'b11;
			 ALUsrc = 1'b1;
			 MtoR = 1'b0;
			 regwrite = 1'b1;
			 memread = 1'b0;
			 memwrite = 1'b0;
			 branch = 1'b0;
		end
		default:
			 ALUop = 2'b10;
    endcase
	end
	
    
end

endmodule
    
