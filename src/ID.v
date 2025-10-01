`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//////////////////////////////////////////////////////////////////////////////////
module ID(clk,Instruction_id, PC_id, RegWrite_wb, rdAddr_wb, RegWriteData_wb, MemRead_ex, 
          rdAddr_ex, MemtoReg_id, RegWrite_id, MemWrite_id, MemRead_id, ALUCode_id, 
			 ALUSrcA_id, ALUSrcB_id,  Stall, Branch, Jump, IFWrite,  JumpAddr, Imm_id,
			 rs1Data_id, rs2Data_id,rs1Addr_id,rs2Addr_id,rdAddr_id);
    input clk;
    input [31:0] Instruction_id;
    input [31:0] PC_id;
    input RegWrite_wb;
    input [4:0] rdAddr_wb;
    input [31:0] RegWriteData_wb;
    input MemRead_ex;
    input [4:0] rdAddr_ex;
    output MemtoReg_id;
    output RegWrite_id;
    output MemWrite_id;
    output MemRead_id;
    output [3:0] ALUCode_id;
    output ALUSrcA_id;
    output [1:0]ALUSrcB_id;
    output Stall;
    output Branch;
    output Jump;
    output IFWrite;
    output [31:0] JumpAddr;
    output [31:0] Imm_id;
    output [31:0] rs1Data_id;
    output [31:0] rs2Data_id;
	output[4:0] rs1Addr_id,rs2Addr_id,rdAddr_id;

    assign rs1Addr_id = Instruction_id[24:20];
    assign rs2Addr_id = Instruction_id[19:15];
    assign rdAddr_id = Instruction_id[11:7];        //比较 rdAddr_id, rdAddr_wb, rdAddr_ex

    // 寄存器堆
    RAWRegs u_RAWRegs(
        .clk       	(clk         ),
        .rs1Addr   	(rs1Addr_id  ),
        .rs2Addr   	(rs2Addr_id  ),
        .WriteAddr 	(rdAddr_id   ),
        .RegWrite  	(RegWrite_id ),
        .WriteData 	(RegWriteData_wb),
        .rs1Data   	(rs1Data_id  ),
        .rs2Data   	(rs2Data_id  )
    );

    // 指令译码
    wire JALR;
    wire [31:0] offset;
    wire SB_type;
    wire [2:0] funct3;
    
    Decode u_Decode(
        .Instruction 	(Instruction_id ),
        .MemtoReg    	(MemtoReg_id    ),
        .RegWrite    	(RegWrite_id    ),
        .MemWrite    	(MemWrite_id    ),
        .MemRead     	(MemRead_id     ),
        .ALUCode     	(ALUCode_id     ),
        .ALUSrcA     	(ALUSrcA_id     ),
        .ALUSrcB     	(ALUSrcB_id     ),
        .Jump        	(Jump           ),
        .JALR        	(JALR           ),
        .Imm         	(Imm_id         ),
        .offset      	(offset         ),
        .SB_type     	(SB_type        ),
        .funct3      	(funct3         )
    );

    // 分支检测
    BranchTest u_BranchTest(
        .rs1Data 	(rs1Data_id ),
        .rs2Data 	(rs2Data_id ),
        .SB_type 	(SB_type    ),
        .funct3  	(funct3     ),
        .Branch  	(Branch     )
    );
    
    // 冒险检测
    HazardDetector u_HazardDetector(
        .rdAddr_ex  	(rdAddr_ex   ),
        .rs1Addr    	(rs1Addr_id  ),
        .rs2Addr    	(rs2Addr_id  ),
        .MemRead_ex 	(MemRead_ex  ),
        .Stall      	(Stall       ),
        .IFWrite    	(IFWrite     )
    );
    
    ALU_add u_Jump_add(
        .a  	(PC_id    ),
        .b  	(offset   ),
        .ci 	(1'b0     ),
        .s  	(JumpAddr ),
        .co 	(         )
    );
    
    
endmodule
