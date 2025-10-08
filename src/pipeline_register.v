module IF_ID_reg(
    input clk,
    input en,
    input rst,
    input top_rst,
    input [31:0] Instruction_if,
    input [31:0] PC_if,
    output reg [31:0] Instruction_id,
    output reg [31:0] PC_id
    );

    always @(posedge clk) begin
        if (top_rst) begin
            PC_id <= 32'd0;
            Instruction_id <= 32'd0;
        end
        else if (en) begin
            if (rst) begin
                PC_id <= 32'd0;
                Instruction_id <= 32'd0;
            end
            else begin
                PC_id <= PC_if;
                Instruction_id <= Instruction_if;
            end
        end
        else ;
    end

endmodule

module ID_EX_reg(
    input clk,
    input rst,
    input top_rst,
    // WB
    input MemtoReg_id,
    input RegWrite_id,
    // M
    input MemWrite_id,
    input MemRead_id,
    // EX
    input [3:0] ALUCode_id,
    input ALUSrcA_id,
    input [1:0]ALUSrcB_id,
    // 
    input [31:0] PC_id,
    input [31:0] Instruction_id,
    input [31:0] Imm_id,
    input [31:0] rs1Data_id,
    input [31:0] rs2Data_id,
	input [4:0]  rs1Addr_id,
    input [4:0]  rs2Addr_id,
    input [4:0]  rdAddr_id,

    // WB
    output reg MemtoReg_ex,
    output reg RegWrite_ex,
    // M
    output reg MemWrite_ex,
    output reg MemRead_ex,
    //EX
    output reg [3:0] ALUCode_ex,
    output reg ALUSrcA_ex,
    output reg [1:0] ALUSrcB_ex,
    // 
	output reg [31:0] PC_ex,
    output reg [31:0] Instruction_ex,
    output reg [31:0] Imm_ex,
    output reg [31:0] rs1Data_ex,
    output reg [31:0] rs2Data_ex,
    output reg [4:0]  rs1Addr_ex,
    output reg [4:0]  rs2Addr_ex,
    output reg [4:0]  rdAddr_ex
    );

    always @(posedge clk) begin
        if (rst || top_rst) begin
            MemtoReg_ex <= 1'b0;
            RegWrite_ex <= 1'b0;
            MemWrite_ex <= 1'b0;
            MemRead_ex <= 1'b0;
            ALUCode_ex <= 4'b0;
            ALUSrcA_ex <= 1'b0;
            ALUSrcB_ex <= 2'b0;
            PC_ex <= 32'b0;
            Imm_ex <= 32'b0;
            rs1Data_ex <= 32'b0;
            rs2Data_ex <= 32'b0;
            rs1Addr_ex <= 5'b0;
            rs2Addr_ex <= 5'b0;
            rdAddr_ex <= 5'b0;
        end
        else begin
            MemtoReg_ex <= MemtoReg_id;
            RegWrite_ex <= RegWrite_id;
            MemWrite_ex <= MemWrite_id;
            MemRead_ex <= MemRead_id;
            ALUCode_ex <= ALUCode_id;
            ALUSrcA_ex <= ALUSrcA_id;
            ALUSrcB_ex <= ALUSrcB_id;
            PC_ex <= PC_id;
            Instruction_ex <= Instruction_id;
            Imm_ex <= Imm_id;
            rs1Data_ex <= rs1Data_id;
            rs2Data_ex <= rs2Data_id;
            rs1Addr_ex <= rs1Addr_id;
            rs2Addr_ex <= rs2Addr_id;
            rdAddr_ex <= rdAddr_id;
        end
    end

endmodule

module EX_MEM_reg(
    input clk,
    input top_rst,
    // WB
    input MemtoReg_ex,
    input RegWrite_ex,
    // M
    input MemWrite_ex,
    // 
    input [31:0] ALUResult_ex,
    input [31:0] MemWriteData_ex,
    input [4:0]  rdAddr_ex,

    // WB
    output reg MemtoReg_mem,
    output reg RegWrite_mem,
    // M
    output reg MemWrite_mem,
    // 
    output reg [31:0] ALUResult_mem,
    output reg [31:0] MemWriteData_mem,
    output reg [4:0] rdAddr_mem,

    // debug
    input [31:0] Instruction_ex,
    input [31:0] PC_ex,
    output reg [31:0] Instruction_mem,
    output reg [31:0] PC_mem
    );

    always @(posedge clk) begin
        if (top_rst) begin
            MemtoReg_mem <= 1'b0;
            RegWrite_mem <= 1'b0;
            MemWrite_mem <= 1'b0;
            ALUResult_mem <= 32'b0;
            MemWriteData_mem <= 32'b0;
            rdAddr_mem <= 5'b0;
        end
        else begin
            MemtoReg_mem <= MemtoReg_ex;
            RegWrite_mem <= RegWrite_ex;
            MemWrite_mem <= MemWrite_ex;
            ALUResult_mem <= ALUResult_ex;
            MemWriteData_mem <= MemWriteData_ex;
            rdAddr_mem <= rdAddr_ex;
            Instruction_mem <= Instruction_ex;
            PC_mem <= PC_ex;
        end
    end

endmodule

module MEM_WB_reg(
    input clk,
    input top_rst,
    //WB
    input MemtoReg_mem,
    input RegWrite_mem,
    //
    input [31:0] MemDout_mem,
    input [31:0] ALUResult_mem,
    input [4:0]  rdAddr_mem,

    // WB
    output reg MemtoReg_wb,
    output reg RegWrite_wb,
    // 
    output reg [31:0] MemDout_wb,
    output reg [31:0] ALUResult_wb,
    output reg [4:0] rdAddr_wb,

    // debug
    input [31:0] Instruction_mem,
    input [31:0] PC_mem,
    output reg [31:0] Instruction_wb,
    output reg [31:0] PC_wb
);

    always @(posedge clk) begin
        if (top_rst)begin
            MemtoReg_wb <= 1'b0;
            RegWrite_wb <= 1'b0;
            MemDout_wb <= 32'b0;
            ALUResult_wb <= 32'b0;
            rdAddr_wb <= 5'b0;
        end
        else begin
            MemtoReg_wb <= MemtoReg_mem;
            RegWrite_wb <= RegWrite_mem;
            MemDout_wb <= MemDout_mem;
            ALUResult_wb <= ALUResult_mem;
            rdAddr_wb <= rdAddr_mem;
            Instruction_wb <= Instruction_mem;
            PC_wb <= PC_mem;
        end
    end

endmodule
