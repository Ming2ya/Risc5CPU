module ALU_add(
    input [31:0] a, b,
    input ci,
    output [31:0] s,
    output co
);
    wire [7:0] c_0, c_1;
    wire [3:0] sum_0[7:0], sum_1[7:0];
    wire [8:0] carry;

    assign carry[0] = ci;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : adder_block
            adder_4bits adder_0(
                .a  	(a[4*i+3 : 4*i] ),
                .b  	(b[4*i+3 : 4*i] ),
                .ci 	(1'b0 ),
                .s  	(sum_0[i] ),
                .co 	(c_0[i] )
            );

            adder_4bits adder_1(
                .a  	(a[4*i+3 : 4*i] ),
                .b  	(b[4*i+3 : 4*i] ),
                .ci 	(1'b1   ),
                .s  	(sum_1[i]  ),
                .co 	(c_1[i] )
            );
            
            assign s[4*i+3 : 4*i] = (carry[i] == 1'b1)? sum_1[i]: sum_0[i];
            assign carry[i + 1] = (carry[i] == 1'b1)? c_1[i]: c_0[i];
        end
    endgenerate
    assign co = carry[8];
endmodule

module adder_4bits(
    input [3:0] a, b,
    input ci,
    output [3:0] s,
    output co
);
    wire [3:0] p, g, c;
    assign p = a | b;
    assign g = a & b;
    assign c[0] = ci;
    assign c[1] = g[0] | p[0] & ci;
    assign c[2] = g[1] | p[1] & g[0] | p[1] & p[0] & ci;
    assign c[3] = g[2] | p[2] & g[1] | p[2] & p[1] & g[0] | p[2] & p[1] & p[0] & ci;
    assign co = g[3] | p[3] & g[2] | p[3] & p[2] & g[1] | p[3] & p[2] & p[1] & g[0] | p[3] & p[2] & p[1] & p[0] & ci;
    assign s = p & ~g ^ c;
endmodule

module ALU_sll(
    input [31:0] a, b,
    output [31:0] s
);
    wire [31:0] temp[4:0];
    assign temp[0] = (b[0] == 1'b1)? a<<1: a;
    assign temp[1] = (b[1] == 1'b1)? temp[0]<<2: temp[0];
    assign temp[2] = (b[2] == 1'b1)? temp[1]<<4: temp[1];
    assign temp[3] = (b[3] == 1'b1)? temp[2]<<8: temp[2];
    assign temp[4] = (b[4] == 1'b1)? temp[3]<<16: temp[3];

    assign s = (|b[31:5] == 1'b1)? 32'b0: temp[4];

endmodule

module ALU_srl(
    input [31:0] a, b,
    output [31:0] s
);
    wire [31:0] temp[4:0];
    assign temp[0] = (b[0] == 1'b1)? a>>1: a;
    assign temp[1] = (b[1] == 1'b1)? temp[0]>>2: temp[0];
    assign temp[2] = (b[2] == 1'b1)? temp[1]>>4: temp[1];
    assign temp[3] = (b[3] == 1'b1)? temp[2]>>8: temp[2];
    assign temp[4] = (b[4] == 1'b1)? temp[3]>>16: temp[3];

    assign s = (|b[31:5] == 1'b1)? 32'b0: temp[4];
    
endmodule

module ALU_sra(
    input [31:0] a, b,
    output [31:0] s
);
    wire [31:0] temp[4:0];
    assign temp[0] = (b[0] == 1'b1)? {{1{a[31]}}, a[31:1]}: a;
    assign temp[1] = (b[1] == 1'b1)? {{2{temp[0][31]}}, temp[0][31:2]}: temp[0];
    assign temp[2] = (b[2] == 1'b1)? {{4{temp[1][31]}}, temp[1][31:4]}: temp[1];
    assign temp[3] = (b[3] == 1'b1)? {{8{temp[2][31]}}, temp[2][31:8]}: temp[2];
    assign temp[4] = (b[4] == 1'b1)? {{16{temp[3][31]}}, temp[3][31:16]}: temp[3];

    assign s = (|b[31:5] == 1'b1)? 32'b0: temp[4];
    
endmodule
