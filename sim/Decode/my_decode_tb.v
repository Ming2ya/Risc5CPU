`timescale 1ns / 1ps
module my_decode_tb;
    // Inputs
    reg [31:0] Instruction;
    // Outputs
    wire MemtoReg;
    wire RegWrite;
    wire MemWrite;
    wire MemRead;
    wire [3:0] ALUCode;
    wire ALUSrcA;
    wire [1:0] ALUSrcB;
    wire Jump;
    wire JALR;
    wire [31:0] Imm,offset;
    // Instantiate the Unit Under Test (UUT)
    Decode uut (
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ALUCode(ALUCode),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .Jump(Jump),
        .JALR(JALR),
        .Imm(Imm),
        .offset(offset),
        .Instruction(Instruction)
    );
    reg error;
    task verify;
        input exp_MemtoReg;
        input exp_RegWrite;
        input exp_MemWrite;
        input exp_MemRead;
        input [3:0] exp_ALUCode;
        input exp_ALUSrcA;
        input [1:0] exp_ALUSrcB;
        input exp_Jump;
        input exp_JALR;
        input [31:0] exp_Imm;
        input [31:0] exp_offset;
    begin
        if(MemtoReg !== exp_MemtoReg) begin
            $display("Error for instr 0x%08h: MemtoReg expected %b, got %b", Instruction, exp_MemtoReg, MemtoReg);
            error = 1;
        end
        if(RegWrite !== exp_RegWrite) begin
            $display("Error for instr 0x%08h: RegWrite expected %b, got %b", Instruction, exp_RegWrite, RegWrite);
            error = 1;
        end
        if(MemWrite !== exp_MemWrite) begin
            $display("Error for instr 0x%08h: MemWrite expected %b, got %b", Instruction, exp_MemWrite, MemWrite);
            error = 1;
        end
        if(MemRead !== exp_MemRead) begin
            $display("Error for instr 0x%08h: MemRead expected %b, got %b", Instruction, exp_MemRead, MemRead);
            error = 1;
        end
        if(ALUCode !== exp_ALUCode) begin
            $display("Error for instr 0x%08h: ALUCode expected 0x%h, got 0x%h", Instruction, exp_ALUCode, ALUCode);
            error = 1;
        end
        if(ALUSrcA !== exp_ALUSrcA) begin
            $display("Error for instr 0x%08h: ALUSrcA expected %b, got %b", Instruction, exp_ALUSrcA, ALUSrcA);
            error = 1;
        end
        if(ALUSrcB !== exp_ALUSrcB) begin
            $display("Error for instr 0x%08h: ALUSrcB expected 0x%h, got 0x%h", Instruction, exp_ALUSrcB, ALUSrcB);
            error = 1;
        end
        if(Jump !== exp_Jump) begin
            $display("Error for instr 0x%08h: Jump expected %b, got %b", Instruction, exp_Jump, Jump);
            error = 1;
        end
        if(JALR !== exp_JALR) begin
            $display("Error for instr 0x%08h: JALR expected %b, got %b", Instruction, exp_JALR, JALR);
            error = 1;
        end
        if(Imm !== exp_Imm) begin
            $display("Error for instr 0x%08h: Imm expected 0x%08h, got 0x%08h", Instruction, exp_Imm, Imm);
            error = 1;
        end
        if(offset !== exp_offset) begin
            $display("Error for instr 0x%08h: offset expected 0x%08h, got 0x%08h", Instruction, exp_offset, offset);
            error = 1;
        end
    end
    endtask
    initial begin
        // dumpfiles
        $dumpfile("my_decode_tb.vcd");
        $dumpvars(0, my_decode_tb);
        // Initialize Inputs
        Instruction = 32'h00000000;
        error = 0;
        // Add stimulus here
        #200 Instruction = 32'h00003f37;	//lui  X30, 0x3000
        #10;
        verify(0,1,0,0,4'h2,0,2'h1,0,0,32'h00003000,32'h00000000);
        #200 Instruction = 32'h02000fe7;	//jalr X31, later(X0)
        #10;
        verify(0,1,0,0,4'h0,1,2'h2,1,1,32'h00000000,32'h00000020);
        #200 Instruction = 32'h00001c63;	//bne  X0, X0, end
        #10;
        verify(0,0,0,0,4'h0,0,2'h1,0,0,32'h00000000,32'h00000018);
        #200 Instruction = 32'h042f0293;	//addi X5, X30, 42
        #10;
        verify(0,1,0,0,4'h0,0,2'h1,0,0,32'h00000042,32'h00000000);
        #200 Instruction = 32'h01f00333;	//add  X6, X0, X31
        #10;
        verify(0,1,0,0,4'h0,0,2'h0,0,0,32'h00000000,32'h00000000);
        #200 Instruction = 32'h406283b3;	//sub  X7, X5, X6
        #10;
        verify(0,1,0,0,4'h1,0,2'h0,0,0,32'h00000000,32'h00000000);
        #200 Instruction = 32'h0053ee33;	//or	 X28, X7, X5
        #10;
        verify(0,1,0,0,4'h5,0,2'h0,0,0,32'h00000000,32'h00000000);
        #200 Instruction = 32'hfc000ae3;	//beq X0, X0, earlier
        #10;
        verify(0,0,0,0,4'h0,0,2'h1,0,0,32'h00000000,32'hffffffd4);
        #200 Instruction = 32'h001c2623;	//sw  X28, 0C(X0)
        #10;
        verify(0,0,1,0,4'h0,0,2'h1,0,0,32'h0000000c,32'h00000000);
        #200 Instruction = 32'h00432e83;	//lw X29, 04(X6)
        #10;
        verify(1,1,0,1,4'h0,0,2'h1,0,0,32'h00000004,32'h00000000);
        #200 Instruction = 32'h002e9293;	//sll X5, X29,2
        #10;
        verify(0,1,0,0,4'h6,0,2'h1,0,0,32'h00000002,32'h00000000);
        #200 Instruction = 32'h00733e33;	//sltu X28, X6,X7
        #10;
        verify(0,1,0,0,4'ha,0,2'h0,0,0,32'h00000000,32'h00000000);
        #200 Instruction = 32'h00000f6f;	//jal  X31, done
        #10;
        verify(0,1,0,0,4'h0,1,2'h2,1,0,32'h00000000,32'h00000000);
        #200 Instruction = 32'h00001117;	//auipc x1, 0x1
        #10;
        verify(0,1,0,0,4'h0,1,2'h1,0,0,32'h00001000,32'h00000000);
        #200 Instruction = 32'hfff32293;	//slti x5, x6, -1
        #10;
        verify(0,1,0,0,4'h9,0,2'h1,0,0,32'hffffffff,32'h00000000);
        #200 Instruction = 32'h40335293;	//srai x5, x6, 3
        #10;
        verify(0,1,0,0,4'h8,0,2'h1,0,0,32'h00000003,32'h00000000);
        #200 Instruction = 32'h01f37293;	//andi x5, x6, 0x1f
        #10;
        verify(0,1,0,0,4'h3,0,2'h1,0,0,32'h0000001f,32'h00000000);
        #200 Instruction = 32'h00734333;	//xor x5, x6, x7
        #10;
        verify(0,1,0,0,4'h4,0,2'h0,0,0,32'h00000000,32'h00000000);
        #200 Instruction = 32'h40735333;	//sra x5, x6, x7
        #10;
        verify(0,1,0,0,4'h8,0,2'h0,0,0,32'h00000000,32'h00000000);
        #200 Instruction = 32'h00a33293;	//sltiu x5, x6, 10
        #10;
        verify(0,1,0,0,4'ha,0,2'h1,0,0,32'h0000000a,32'h00000000);
        #200 Instruction = 32'h00335293;	//srli x5, x6, 3
        #10;
        verify(0,1,0,0,4'h7,0,2'h1,0,0,32'h00000003,32'h00000000);
        #200;
        if(error == 0) $display("All tests passed!");
        #200 $stop;
    end
endmodule