//******************************************************************************
// MIPS verilog model
//
// ALU.v
//******************************************************************************

module ALU (
	// Outputs
	   ALUResult,
	// Inputs
	   ALUCode, A, B);
	input [3:0]	ALUCode;				// Operation select
	input [31:0]	A, B;
	output [31:0]	ALUResult;
	
// Decoded ALU operation select (ALUsel) signals
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

   reg  [31:0] result;
   wire [31:0] b, sum, sll, srl, sra;
   wire Binvert = ~(ALUCode == 1'b0);
   assign b = (Binvert == 1'b0)? B: ~B;
   ALU_add u_ALU_add(
      .a  	(A   ),
      .b  	(b   ),
      .ci 	(Binvert),
      .s  	(sum ),
      .co 	(    )
   );

   ALU_sll u_ALU_sll(
      .a 	(A   ),
      .b 	(B   ),
      .s 	(sll )
   );
   
   ALU_srl u_ALU_srl(
      .a 	(A   ),
      .b 	(B   ),
      .s 	(srl )
   );
   
   ALU_sra u_ALU_sra(
      .a 	(A   ),
      .b 	(B   ),
      .s 	(sra )
   ); 

   wire isLT, isLTU;
   assign isLT = (A[31] & ~B[31]) | ((A[31] == B[31]) & sum[31]);
   assign isLTU = (~A[31] & B[31]) | ((A[31] == B[31]) & sum[31]);

   always @(*) begin
      case (ALUCode)
         alu_add: result = sum;
         alu_sub: result = sum;
         alu_lui: result = {B[31:12] , 12'b0};
         alu_and: result = A & B;
         alu_xor: result = A ^ B;
         alu_or:  result = A | B;
         alu_sll: result = sll;
         alu_srl: result = srl;
         alu_sra: result = sra;
         alu_slt: result = {31'd0, isLT};
         alu_sltu: result = {31'd0, isLTU};
      endcase
   end
   assign ALUResult = result;

endmodule
