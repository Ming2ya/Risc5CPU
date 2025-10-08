`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zju
// Engineer: qmj
//////////////////////////////////////////////////////////////////////////////////
module EX(ALUCode_ex, ALUSrcA_ex, ALUSrcB_ex,Imm_ex, rs1Addr_ex, rs2Addr_ex, rs1Data_ex, 
          rs2Data_ex, PC_ex, RegWriteData_wb, ALUResult_mem,rdAddr_mem, rdAddr_wb, 
		  RegWrite_mem, RegWrite_wb, ALUResult_ex, MemWriteData_ex, ALU_A, ALU_B);
    input [3:0] ALUCode_ex;
    input ALUSrcA_ex;
    input [1:0]ALUSrcB_ex;
    input [31:0] Imm_ex;
    input [4:0]  rs1Addr_ex;
    input [4:0]  rs2Addr_ex;
    input [31:0] rs1Data_ex;
    input [31:0] rs2Data_ex;
	input [31:0] PC_ex;
    input [31:0] RegWriteData_wb;
    input [31:0] ALUResult_mem;
	input [4:0]rdAddr_mem;
    input [4:0] rdAddr_wb;
    input RegWrite_mem;
    input RegWrite_wb;
    output [31:0] ALUResult_ex;
    output [31:0] MemWriteData_ex;
    output [31:0] ALU_A;
    output [31:0] ALU_B;

    wire [1:0] 	ForwardA;
    wire [1:0] 	ForwardB;
    Forward u_Forward(
        .RegWrite_wb  	( RegWrite_wb   ),
        .RegWrite_mem 	( RegWrite_mem  ),
        .rdAddr_wb    	( rdAddr_wb     ),
        .rdAddr_mem   	( rdAddr_mem    ),
        .rs1Addr_ex   	( rs1Addr_ex    ),
        .rs2Addr_ex   	( rs2Addr_ex    ),
        .ForwardA     	( ForwardA      ),
        .ForwardB     	( ForwardB      )
    );

    reg [31:0] A, ALU_A_reg, B, ALU_B_reg;
    always @(*) begin
        case (ForwardA)
            2'b00: A = rs1Data_ex;
            2'b01: A = RegWriteData_wb;
            2'b10: A = ALUResult_mem;
            default: A = 32'd0;
        endcase
        case (ForwardB)
            2'b00: B = rs2Data_ex;
            2'b01: B = RegWriteData_wb;
            2'b10: B = ALUResult_mem;
            default: B = 32'd0;
        endcase
        case (ALUSrcA_ex)
            1'b0: ALU_A_reg = A;
            1'b1: ALU_A_reg = PC_ex;
        endcase
        case (ALUSrcB_ex)
            2'b00: ALU_B_reg = B;
            2'b01: ALU_B_reg = Imm_ex;
            2'b10: ALU_B_reg = 32'd4;
        endcase
    end
    assign ALU_A = ALU_A_reg;
    assign ALU_B = ALU_B_reg;
    assign MemWriteData_ex = B;

    ALU u_ALU(
        .ALUCode   	( ALUCode_ex   ),
        .A         	( ALU_A        ),
        .B         	( ALU_B        ),
        .ALUResult 	( ALUResult_ex )
    );

endmodule

module Forward(
    input RegWrite_wb, RegWrite_mem,
    input [4:0] rdAddr_wb, rdAddr_mem,
    input [4:0] rs1Addr_ex, rs2Addr_ex,
    output [1:0] ForwardA, ForwardB
);
    assign ForwardA[0] = RegWrite_wb & (rdAddr_wb != 0) & (rdAddr_mem != rs1Addr_ex) & (rdAddr_wb == rs1Addr_ex);
    assign ForwardA[1] = RegWrite_mem & (rdAddr_mem != 0) & (rdAddr_mem == rs1Addr_ex);
    assign ForwardB[0] = RegWrite_wb & (rdAddr_wb != 0) & (rdAddr_mem != rs2Addr_ex) & (rdAddr_wb == rs2Addr_ex);
    assign ForwardB[1] = RegWrite_mem & (rdAddr_mem != 0) & (rdAddr_mem == rs2Addr_ex);

endmodule
