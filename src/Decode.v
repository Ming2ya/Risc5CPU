//******************************************************************************
// //
// Decode.v
//******************************************************************************

module Decode(   
	// Outputs
	MemtoReg, RegWrite, MemWrite, MemRead,ALUCode,ALUSrcA,ALUSrcB,Jump,JALR,Imm,offset, SB_type, funct3,
	// Inputs
    Instruction);
	input [31:0]	Instruction;	// current instruction
	output		   MemtoReg;		// use memory output as data to write into register
	output		   RegWrite;		// enable writing back to the register
	output		   MemWrite;		// write to memory
	output         MemRead;
	output [3:0]   ALUCode;         // ALU operation select
	output      	ALUSrcA;
	output [1:0]   ALUSrcB;
	output         Jump;
	output         JALR;
	output[31:0]   Imm,offset;
    // my outputs
    output          SB_type;
    output [2:0]    funct3;
	
//******************************************************************************
//  instruction type decode
//******************************************************************************
	parameter  R_type_op=   7'b0110011;
	parameter  I_type_op=   7'b0010011;
	parameter  SB_type_op=  7'b1100011;
	parameter  LW_op=       7'b0000011;
	parameter  JALR_op=     7'b1100111;
	parameter  SW_op=       7'b0100011;
	parameter  LUI_op=      7'b0110111;
	parameter  AUIPC_op=    7'b0010111;	
	parameter  JAL_op=      7'b1101111;	
//
  //
   parameter  ADD_funct3 =     3'b000 ;
   parameter  SUB_funct3 =     3'b000 ;
   parameter  SLL_funct3 =     3'b001 ;
   parameter  SLT_funct3 =     3'b010 ;
   parameter  SLTU_funct3 =    3'b011 ;
   parameter  XOR_funct3 =     3'b100 ;
   parameter  SRL_funct3 =     3'b101 ;
   parameter  SRA_funct3 =     3'b101 ;
   parameter  OR_funct3 =      3'b110 ;
   parameter  AND_funct3 =     3'b111;
   //
   parameter  ADDI_funct3 =     3'b000 ;
   parameter  SLLI_funct3 =     3'b001 ;
   parameter  SLTI_funct3 =     3'b010 ;
   parameter  SLTIU_funct3 =    3'b011 ;
   parameter  XORI_funct3 =     3'b100 ;
   parameter  SRLI_funct3 =     3'b101 ;
   parameter  SRAI_funct3 =     3'b101 ;
   parameter  ORI_funct3 =      3'b101 ;
   parameter  ANDI_funct3 =     3'b111;
   //
   parameter	 alu_add=  4'b0000;
   parameter	 alu_sub=  4'b0001;
   parameter	 alu_lui=  4'b0010;
   parameter	 alu_and=  4'b0011;
   parameter	 alu_xor=  4'b0100;
   parameter	 alu_or =  4'b0101;
   parameter 	 alu_sll=  4'b0110;
   parameter	 alu_srl=  4'b0111;
   parameter	 alu_sra=  4'b1000;
   parameter	 alu_slt=  4'b1001;
   parameter	 alu_sltu= 4'b1010; 

//******************************************************************************
// instruction field
//******************************************************************************
	wire [6:0]		op;
	wire  	 	    funct6_7;
	//wire [2:0]		funct3;         转为输出
	assign op			= Instruction[6:0];
	assign funct6_7		= Instruction[30];
 	assign funct3		= Instruction[14:12];
	
    wire R_type, I_type, LW, SW, LUI, AUIPC, JAL;  // JALR, SB_type为输出
    assign R_type = (op == R_type_op);
    assign I_type = (op == I_type_op);
    assign SB_type = (op == SB_type_op);
    assign LW = (op == LW_op);
    assign JALR = (op == JALR_op);
    assign SW = (op == SW_op);
    assign LUI = (op == LUI_op);
    assign AUIPC = (op == AUIPC_op);
    assign JAL = (op == JAL_op);

    assign MemtoReg = LW;
    assign MemRead = LW;
    assign MemWrite = SW;
    assign RegWrite = R_type | I_type | LW | JALR | LUI | AUIPC | JAL;
    assign Jump = JAL | JALR;
    assign ALUSrcA = JALR | JAL | AUIPC;
    assign ALUSrcB[0] = ~(R_type | JAL | JALR);
    assign ALUSrcB[1] = JAL | JALR;

    reg [31:0] ALUCode_reg;
    always @(*) begin
        casex ({R_type, I_type, LUI, funct3})
            6'b100_000: ALUCode_reg = (funct6_7 == 1'b1)? 4'd1: 4'd0;
            6'b100_001: ALUCode_reg = 4'd6;
            6'b100_010: ALUCode_reg = 4'd9;
            6'b100_011: ALUCode_reg = 4'd10;
            6'b100_100: ALUCode_reg = 4'd4;
            6'b100_101: ALUCode_reg = (funct6_7 == 1'b1)? 4'd8: 4'd7;
            6'b100_110: ALUCode_reg = 4'd5;
            6'b100_111: ALUCode_reg = 4'd3;

            6'b010_000: ALUCode_reg = 4'd0;
            6'b010_001: ALUCode_reg = 4'd6;
            6'b010_010: ALUCode_reg = 4'd9;
            6'b010_011: ALUCode_reg = 4'd10;
            6'b010_100: ALUCode_reg = 4'd4;
            6'b010_101: ALUCode_reg = (funct6_7 == 1'b1)? 4'd8: 4'd7;
            6'b010_110: ALUCode_reg = 4'd5;
            6'b010_111: ALUCode_reg = 4'd3;

            6'b001_xxx: ALUCode_reg = 4'd2;
            default: ALUCode_reg = 4'd0;
        endcase             //不将funct6_7纳入匹配会降低鲁棒性吗？
    end
    assign ALUCode = ALUCode_reg;

    wire shift;
    reg [31:0] Imm_reg, offset_reg;
    assign shift = (funct3 == 3'd1) | (funct3 == 3'd5);
    always @(*) begin
        if(I_type == 1'b1)
            Imm_reg = (shift == 1'b1)? {27'd0, Instruction[24:20]}: {{20{Instruction[31]}}, Instruction[31:20]};
        else if (LW == 1'b1)
            Imm_reg = {{20{Instruction[31]}}, Instruction[31:20]};
        else if (SW == 1'b1)
            Imm_reg = {{20{Instruction[31]}}, Instruction[31:25], Instruction[11:7]};
        else if (LUI == 1'b1 || AUIPC == 1'b1)
            Imm_reg = {Instruction[31:12], 12'd0};
        else 
            Imm_reg = 32'd0;

        if (JALR == 1'b1)
            offset_reg = {{20{Instruction[31]}}, Instruction[31:20]};
        else if (JAL == 1'b1)
            offset_reg = {{11{Instruction[31]}}, Instruction[31], Instruction[19:12], Instruction[20], Instruction[30:21], 1'b0};
        else if (SB_type == 1'b1)
            offset_reg = {{19{Instruction[31]}}, Instruction[31], Instruction[7], Instruction[30:25], Instruction[11:8], 1'b0};
        else 
            offset_reg = 32'd0;
    end
    assign Imm = Imm_reg;
    assign offset = offset_reg;
	 
endmodule
