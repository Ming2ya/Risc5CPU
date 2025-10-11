`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: zju
// Engineer: qmj
//////////////////////////////////////////////////////////////////////////////////
module Risc5CPU(clk, reset, JumpFlag, Instruction_id, ALU_A, 
                     ALU_B, ALUResult_ex, PC, MemDout_mem,Stall);
    input clk;
    input reset;
    output[1:0] JumpFlag;
    output [31:0] Instruction_id;
    output [31:0] ALU_A;
    output [31:0] ALU_B;
    output [31:0] ALUResult_ex;
    output [31:0] PC;
    output [31:0] MemDout_mem;
    output Stall;

//¶Ë¿ÚÉùÃ÷
    // ¿ØÖÆÐÅºÅ
    wire        IF_flush;
    wire        Branch;
    wire        Jump;
    //wire        Stall
    wire        IFWrite;
    wire [31:0] JumpAddr;
    //

    // IF
    wire [31:0] Instruction_if;
    wire [31:0] PC_if;
    //

    // ID
    wire [31:0] Instruction_id;
    wire [31:0] PC_id;
    wire        MemtoReg_id;
    wire        RegWrite_id;
    wire        MemWrite_id;
    wire        MemRead_id;
    wire [3:0]  ALUCode_id;
    wire        ALUSrcA_id;
    wire [1:0]  ALUSrcB_id;
    wire [31:0] Imm_id;
    wire [31:0] rs1Data_id;
    wire [31:0] rs2Data_id;
    wire [4:0]  rs1Addr_id;
    wire [4:0]  rs2Addr_id;
    wire [4:0]  rdAddr_id;
    //

    // EX
    wire        MemtoReg_ex;
    wire        RegWrite_ex;
    wire        MemWrite_ex;
    wire        MemRead_ex;
    wire [3:0]  ALUCode_ex;
    wire        ALUSrcA_ex;
    wire [1:0]  ALUSrcB_ex;
    wire [31:0] PC_ex;
    wire [31:0] Instruction_ex;
    wire [31:0] Imm_ex;
    wire [31:0] rs1Data_ex;
    wire [31:0] rs2Data_ex;
    wire [4:0]  rs1Addr_ex;
    wire [4:0]  rs2Addr_ex;
    wire [4:0]  rdAddr_ex;
    wire [31:0] ALUResult_ex;
    wire [31:0] MemWriteData_ex;
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    //

    // MEM
    wire        MemtoReg_mem;
    wire        RegWrite_mem;
    wire        MemWrite_mem;
    wire [31:0] ALUResult_mem;
    wire [31:0] MemWriteData_mem;
    //wire [31:0] MemDout_mem;
    wire [4:0]  rdAddr_mem;
    //

    // WB
    wire        MemtoReg_wb;
    wire        RegWrite_wb;
    wire [31:0] MemDout_wb;
    wire [31:0] ALUResult_wb;
    wire [31:0] RegWriteData_wb;
    wire [4:0]  rdAddr_wb;
    //

    // debug
    wire [31:0] Instruction_mem;
    wire [31:0] Instruction_wb;
    wire [31:0] PC_mem;
    wire [31:0] PC_wb;
//

//
    // IF Ä£¿é
    IF1 u_IF1(
        .clk            	( clk            ),
        .reset          	( reset          ),
        .Branch         	( Branch         ),
        .Jump           	( Jump           ),
        .IFWrite        	( IFWrite        ),
        .JumpAddr       	( JumpAddr       ),
        .Instruction_if 	( Instruction_if ),
        .PC             	( PC_if          ),
        .IF_flush       	( IF_flush       )
    );
    //

    // IF/ID ¼Ä´æÆ÷
    IF_ID_reg u_IF_ID_reg(
        .clk            	( clk             ),
        .en             	( IFWrite         ),
        .rst            	( IF_flush        ),
        .top_rst            ( reset           ),
        .Instruction_if 	( Instruction_if  ),
        .PC_if          	( PC_if           ),
        .Instruction_id 	( Instruction_id  ),
        .PC_id          	( PC_id           )
    );
    //

    // ID Ä£¿é
    ID u_ID(
        .clk             	( clk              ),
        .Instruction_id  	( Instruction_id   ),
        .PC_id           	( PC_id            ),
        .RegWrite_wb     	( RegWrite_wb      ),
        .rdAddr_wb       	( rdAddr_wb        ),
        .RegWriteData_wb 	( RegWriteData_wb  ),
        .MemRead_ex      	( MemRead_ex       ),
        .rdAddr_ex       	( rdAddr_ex        ),
        .MemtoReg_id     	( MemtoReg_id      ),
        .RegWrite_id     	( RegWrite_id      ),
        .MemWrite_id     	( MemWrite_id      ),
        .MemRead_id      	( MemRead_id       ),
        .ALUCode_id      	( ALUCode_id       ),
        .ALUSrcA_id      	( ALUSrcA_id       ),
        .ALUSrcB_id      	( ALUSrcB_id       ),
        .Stall           	( Stall            ),
        .Branch          	( Branch           ),
        .Jump            	( Jump             ),
        .IFWrite         	( IFWrite          ),
        .JumpAddr        	( JumpAddr         ),
        .Imm_id          	( Imm_id           ),
        .rs1Data_id      	( rs1Data_id       ),
        .rs2Data_id      	( rs2Data_id       ),
        .rs1Addr_id      	( rs1Addr_id       ),
        .rs2Addr_id      	( rs2Addr_id       ),
        .rdAddr_id       	( rdAddr_id        )
    );
    //

    // ID/EX ¼Ä´æÆ÷
    ID_EX_reg u_ID_EX_reg(
        .clk         	( clk          ),
        .rst         	( Stall        ),
        .MemtoReg_id 	( MemtoReg_id  ),
        .RegWrite_id 	( RegWrite_id  ),
        .MemWrite_id 	( MemWrite_id  ),
        .MemRead_id  	( MemRead_id   ),
        .ALUCode_id  	( ALUCode_id   ),
        .ALUSrcA_id  	( ALUSrcA_id   ),
        .ALUSrcB_id  	( ALUSrcB_id   ),
        .PC_id       	( PC_id        ),
        .Imm_id      	( Imm_id       ),
        .rs1Data_id  	( rs1Data_id   ),
        .rs2Data_id  	( rs2Data_id   ),
        .rs1Addr_id  	( rs1Addr_id   ),
        .rs2Addr_id  	( rs2Addr_id   ),
        .rdAddr_id   	( rdAddr_id    ),
        .MemtoReg_ex 	( MemtoReg_ex  ),
        .RegWrite_ex 	( RegWrite_ex  ),
        .MemWrite_ex 	( MemWrite_ex  ),
        .MemRead_ex  	( MemRead_ex   ),
        .ALUCode_ex  	( ALUCode_ex   ),
        .ALUSrcA_ex  	( ALUSrcA_ex   ),
        .ALUSrcB_ex  	( ALUSrcB_ex   ),
        .PC_ex       	( PC_ex        ),
        .Imm_ex      	( Imm_ex       ),
        .rs1Data_ex  	( rs1Data_ex   ),
        .rs2Data_ex  	( rs2Data_ex   ),
        .rs1Addr_ex  	( rs1Addr_ex   ),
        .rs2Addr_ex  	( rs2Addr_ex   ),
        .rdAddr_ex   	( rdAddr_ex    ),
        .Instruction_ex (Instruction_ex),
        .Instruction_id (Instruction_id)
    );
    //

    // EX Ä£¿é
    EX u_EX(
        .ALUCode_ex      	( ALUCode_ex       ),
        .ALUSrcA_ex      	( ALUSrcA_ex       ),
        .ALUSrcB_ex      	( ALUSrcB_ex       ),
        .Imm_ex          	( Imm_ex           ),
        .rs1Addr_ex      	( rs1Addr_ex       ),
        .rs2Addr_ex      	( rs2Addr_ex       ),
        .rs1Data_ex      	( rs1Data_ex       ),
        .rs2Data_ex      	( rs2Data_ex       ),
        .PC_ex           	( PC_ex            ),
        .RegWriteData_wb 	( RegWriteData_wb  ),
        .ALUResult_mem   	( ALUResult_mem    ),
        .rdAddr_mem      	( rdAddr_mem       ),
        .rdAddr_wb       	( rdAddr_wb        ),
        .RegWrite_mem    	( RegWrite_mem     ),
        .RegWrite_wb     	( RegWrite_wb      ),
        .ALUResult_ex    	( ALUResult_ex     ),
        .MemWriteData_ex 	( MemWriteData_ex  ),
        .ALU_A           	( ALU_A            ),
        .ALU_B           	( ALU_B            )
    );
    //

    // EX/MEM ¼Ä´æÆ÷
    EX_MEM_reg u_EX_MEM_reg(
        .clk              	( clk               ),
        .MemtoReg_ex      	( MemtoReg_ex       ),
        .RegWrite_ex      	( RegWrite_ex       ),
        .MemWrite_ex      	( MemWrite_ex       ),
        .ALUResult_ex     	( ALUResult_ex      ),
        .MemWriteData_ex  	( MemWriteData_ex   ),
        .rdAddr_ex        	( rdAddr_ex         ),
        .MemtoReg_mem     	( MemtoReg_mem      ),
        .RegWrite_mem     	( RegWrite_mem      ),
        .MemWrite_mem     	( MemWrite_mem      ),
        .ALUResult_mem    	( ALUResult_mem     ),
        .MemWriteData_mem 	( MemWriteData_mem  ),
        .rdAddr_mem       	( rdAddr_mem        ),
        .Instruction_ex     ( Instruction_ex    ),
        .Instruction_mem    ( Instruction_mem   ),
        .PC_ex              ( PC_ex             ),
        .PC_mem             ( PC_mem            )
    );
    //

    // MEM Ä£¿é
    DataRAM u_DataRAM(
        .a   	( ALUResult_mem[7:2] ),
        .d   	( MemWriteData_mem   ),
        .clk 	( clk                ),
        .we  	( MemWrite_mem       ),
        .spo 	( MemDout_mem        )
    );
    //

    // MEM/WB Ä£¿é
    MEM_WB_reg u_MEM_WB_reg(
        .clk           	( clk            ),
        .MemtoReg_mem  	( MemtoReg_mem   ),
        .RegWrite_mem  	( RegWrite_mem   ),
        .MemDout_mem   	( MemDout_mem    ),
        .ALUResult_mem 	( ALUResult_mem  ),
        .rdAddr_mem    	( rdAddr_mem     ),
        .MemtoReg_wb   	( MemtoReg_wb    ),
        .RegWrite_wb   	( RegWrite_wb    ),
        .MemDout_wb    	( MemDout_wb     ),
        .ALUResult_wb  	( ALUResult_wb   ),
        .rdAddr_wb     	( rdAddr_wb      ),
        .Instruction_mem( Instruction_mem),
        .Instruction_wb ( Instruction_wb ),
        .PC_mem         ( PC_mem         ),
        .PC_wb          ( PC_wb          )
    );
    //
    
    // WB Ä£¿é
    assign RegWriteData_wb = (MemtoReg_wb == 1'b1)? MemDout_wb: ALUResult_wb;
    //

    assign PC = PC_if;
    assign JumpFlag = {Jump, Branch};

endmodule
