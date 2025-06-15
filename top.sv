module top(
	input logic rst,clk);
	
	//Before the IF-ID Pipeline register
	logic [34:0]btb[0:31];
	logic [31:0]PCin,PCout; //Program Counter
	logic [31:0]instruction; //instruction from memory
	logic [31:0]newPC; //PC <- PC + 4
	logic [63:0]IFIDin = {newPC,instruction};

	logic PCwrite;
    logic PCsrc;
	logic ifidwrite;
	logic stall;
	
	adder #(.N(32)) add1(newPC,PCout,32'd1); //Full adder for incrementing PC
	instr_mem imem(instruction,PCout,clk,rst); //Instr Memory
	
	
	//Between IF-ID and ID-EX Pipeline registers
	logic [63:0]IFIDout;
	logic [31:0]IFID_PC_out;
	logic [31:0]IFID_instr_out;
	logic [6:0]opcode;
	logic [2:0]funct3;
	logic [6:0]funct7;
	logic [4:0]Rs1,Rs2,Rd;
	logic [31:0]immgen_out,Rs1data,Rs2data;
	
	logic [160:0]IDEXin;
	
	logic [1:0]ALUop;
	logic ALUsrc,MtoR,regwrite,memread,memwrite,branch;
	logic [7:0]controlsig = {ALUop,ALUsrc,MtoR,regwrite,memread,memwrite,branch};//control signals
	logic [7:0]controlsig_f;

	assign IFID_PC_out = IFIDout[63:32];
	assign IFID_instr_out = IFIDout[31:0];
	assign opcode = IFIDout[6:0];
	assign funct3 = IFIDout[14:12];
	assign funct7 = IFIDout[31:25];
	assign Rs1 = IFIDout[19:15];
	assign Rs2 = IFIDout[24:20];
	assign Rd = IFIDout[11:7];
	assign IDEXin = {Rs1,Rs2,IFID_PC_out,Rs1data,Rs2data,immgen_out,funct7,funct3,Rd,controlsig_f};//Signals to be passed to EX stage
	
	pipo_reg #(.N(64)) IFID(IFIDout,IFIDin,clk,rst || PCsrc ,ifidwrite); //Program Counter
	controlunit CU(opcode,rst,ALUop,ALUsrc,MtoR,regwrite,memread,memwrite,branch);//Main Control Unit
	imm_gen IG(immgen_out,IFID_instr_out,opcode);//Immediate generator depending on instruction type
	
	
	//Between ID-EX and EX-MEM Pipeline registers
	logic [160:0]IDEXout;
	logic [2:0]funct3_EX;
	logic [6:0]funct7_EX;
	logic [4:0]Rd_EX;
	logic [4:0]Rs1_EX;
	logic [4:0]Rs2_EX;
	logic [31:0]Rs1data_EX,Rs2data_EX,immgen_out_EX,ALUsrcb;
	logic [31:0]IDEX_PC_out;
	logic [7:0]controlsig_EX;
	logic [31:0]BRadd;
	logic [3:0]ALUoperation;
	logic [31:0]result;
	logic zeroflag;
	logic [1:0]forwardA,forwardB;
	logic [31:0]ALUsrc1,ALUsrc2;
	
	logic [106:0]EXMEMin;
	
	assign Rs1_EX = IDEXout[160:156];
	assign Rs2_EX = IDEXout[155:151];
	assign IDEX_PC_out = IDEXout[150:119];
	assign Rs1data_EX = IDEXout[118:87];
	assign Rs2data_EX = IDEXout[86:55];
	assign immgen_out_EX = IDEXout[54:23];
	assign funct7_EX = IDEXout[22:16];
	assign funct3_EX = IDEXout[15:13];
	assign Rd_EX = IDEXout[12:8];
	assign controlsig_EX = IDEXout[7:0];
	
	assign EXMEMin = {controlsig_EX[4:0],BRadd,zeroflag,result,ALUsrcb,Rd_EX};
	
	pipo_reg #(.N(161)) IDEX(IDEXout,IDEXin,clk,rst || PCsrc,1'b1); 
	ALUcontrol ALUC(controlsig_EX[7:6], funct7_EX, funct3_EX, ALUoperation);
	ALU A1(clk, ALUsrc1, ALUsrc2, ALUoperation, result, zeroflag);
	mux32 #(.N(32)) m1(ALUsrc2,ALUsrcb,immgen_out_EX,controlsig_EX[5]);
	adder #(.N(32)) add2(BRadd,IDEX_PC_out,{immgen_out_EX[30:0],1'b0}); //Full adder PC+offset


	//Between EX-MEM and MEM-WB Pipeline registers
	logic [106:0]EXMEMout;
	logic [4:0]controlsig_MEM;
	logic [31:0]PCsrcB;
	logic [31:0]dmemaddr,dmemdata;
	logic [31:0]re_data;
	logic [4:0]Rd_MEM;
	logic zero_br;

	logic [70:0]MEMWBin;
	
	assign PCsrc = zero_br & controlsig_MEM[0];
	assign Rd_MEM = EXMEMout[4:0];
	assign dmemdata = EXMEMout[36:5];
	assign dmemaddr = EXMEMout[68:37];
	assign zero_br = EXMEMout[69];
	assign PCsrcB = EXMEMout[101:70];
	assign controlsig_MEM = EXMEMout[106:102];
	
	assign MEMWBin = {controlsig_MEM[4:3],re_data,dmemaddr,Rd_MEM};
	
	pipo_reg #(.N(107)) EXMEM(EXMEMout,EXMEMin,clk,rst,1'b1); 
	data_mem dmem(clk,controlsig_MEM[2],controlsig_MEM[1],dmemaddr,dmemdata,re_data);
	
	//After MEM-WB Pipeline Register
	logic [70:0]MEMWBout;
	logic [31:0]WBsrcA,WBsrcB;
	logic [1:0]controlsig_WB;
	logic [4:0]Rd_WB;
	logic [31:0]writedata;
	
	assign Rd_WB = MEMWBout[4:0];
	assign WBsrcB = MEMWBout[36:5];
	assign WBsrcA = MEMWBout[68:37];
	assign controlsig_WB = MEMWBout[70:69];
	
	pipo_reg #(.N(71)) MEMWB(MEMWBout,MEMWBin,clk,rst,1'b1);
	mux32 #(.N(32)) M3(writedata,WBsrcB,WBsrcA,controlsig_WB[1]);
	regfile Rfile(Rs1,Rs2,Rd_WB,writedata,controlsig_WB[0],clk,rst,Rs1data,Rs2data);//Register File
	pipo_reg #(.N(32)) PC(PCout,PCin,clk,rst,PCwrite); //Program Counter
	mux32 #(.N(32)) M1(PCin,newPC,PCsrcB,PCsrc);

	fwdunit f1(Rs1_EX,Rs2_EX,controlsig_EX[3],Rd_MEM,controlsig_WB[0],Rd_WB,ALUop,forwardA,forwardB);
	mux4_1 alumux1(ALUsrc1,Rs1data_EX,writedata,dmemaddr,32'b0,forwardA);
	mux4_1 alumux2(ALUsrcb,Rs2data_EX,writedata,dmemaddr,32'b0,forwardB);
	hzdunit h1(Rs1,Rs2,controlsig_EX[2],Rd_EX,PCwrite,ifidwrite,stall);
	mux32 #(.N(8)) csmux(controlsig_f,controlsig,8'b0,stall);

endmodule
	
	
