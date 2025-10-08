`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  zju
// Engineer: qmj
//////////////////////////////////////////////////////////////////////////////////
module IF1(clk, reset, Branch,Jump, IFWrite, JumpAddr,Instruction_if,PC,IF_flush);
    input clk;
    input reset;
    input Branch;
    input Jump;
    input IFWrite;
    input [31:0] JumpAddr;
    output [31:0] Instruction_if;
    output [31:0] PC;
    output IF_flush;

    reg  [31:0] IF_PC;
    wire [31:0] PC_add;
    wire PC_sel;
    assign PC_sel = Jump | Branch;

    ALU_add u_PC_add(
        .a  	(IF_PC   ),
        .b  	(32'd4   ),
        .ci 	(1'b0    ),
        .s  	(PC_add  ),
        .co 	(        )
    );
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_PC <= 32'd0;
        end
        else if (IFWrite) begin
            IF_PC <= (PC_sel == 1'b1)? JumpAddr: PC_add;
        end
        else ;
    end
    
    InstructionROM u_InstructionROM(
        .addr 	(IF_PC[7:2]     ),
        .dout 	(Instruction_if )
    );
    
    assign PC = IF_PC;
    assign IF_flush = PC_sel;

endmodule
