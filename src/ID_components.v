module RAWRegs(
    input clk, reset,
    input [4:0] rs1Addr, rs2Addr, WriteAddr,
    input RegWrite,
    input [31:0] WriteData,
    output [31:0] rs1Data, rs2Data
);
    wire [31:0] ReadData1, ReadData2;
    wire rs1Sel, rs2Sel;

    reg [31:0]regs [31:0];
    assign ReadData1 = (rs1Addr == 5'd0)? 32'd0: regs[rs1Addr];
    assign ReadData2 = (rs2Addr == 5'd0)? 32'd0: regs[rs2Addr];
    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0; 
            end
        end
        else if (RegWrite)
            regs[WriteAddr] <= WriteData;
        else ;
    end

    assign rs1Sel = RegWrite & (WriteAddr != 1'b0) & (WriteAddr == rs1Addr);
    assign rs2Sel = RegWrite & (WriteAddr != 1'b0) & (WriteAddr == rs2Addr);

    assign rs1Data = (rs1Sel == 1'b0)? ReadData1: WriteData;
    assign rs2Data = (rs2Sel == 1'b0)? ReadData2: WriteData;

endmodule

module BranchTest(
    input [31:0] rs1Data, rs2Data,
    input SB_type,
    input [2:0] funct3,
    output Branch
);
    parameter  BEQ_funct3  = 3'b000;
    parameter  BNE_funct3  = 3'b001;
    parameter  BLT_funct3  = 3'b100;
    parameter  BGE_funct3  = 3'b101;
    parameter  BLTU_funct3 = 3'b110;
    parameter  BGEU_funct3 = 3'b111;

    wire [31:0] sum;
    ALU_add u_Branch_add(
        .a  	(rs1Data ),
        .b  	(~rs2Data),
        .ci 	(1'b1    ),
        .s  	(sum     ),
        .co 	(        )
    );
    
    wire isLT, isLTU;
    reg BranchReg;
    assign isLT = (rs1Data[31] & ~rs2Data[31]) | ((rs1Data[31] == rs2Data[31]) & sum[31]);
    assign isLTU = (~rs1Data[31] & rs2Data[31]) | ((rs1Data[31] == rs2Data[31]) & sum[31]);
    always @(*) begin
        if (SB_type) begin
            case(funct3)
                BEQ_funct3: BranchReg = ~(|sum);
                BNE_funct3: BranchReg = |sum;
                BLT_funct3: BranchReg = isLT;
                BGE_funct3: BranchReg = ~isLT;
                BLTU_funct3: BranchReg = isLTU;
                BGEU_funct3: BranchReg = ~isLTU;
                default: BranchReg = 0;
            endcase
        end
        else BranchReg = 0;
    end
    assign Branch = BranchReg;

endmodule

module HazardDetector(
    input [4:0] rdAddr_ex, rs1Addr, rs2Addr,
    input MemRead_ex,
    output Stall, IFWrite
);
    assign Stall = ((rdAddr_ex == rs1Addr) | (rdAddr_ex == rs2Addr)) & MemRead_ex;
    assign IFWrite = ~Stall;

endmodule
