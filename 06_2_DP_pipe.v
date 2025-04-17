`include "/home/p0975633233/00_Other/00_ALU/ALU/00_unpack.v"
`include "/home/p0975633233/00_Other/00_ALU/ALU/01_mul.v"
`include "/home/p0975633233/00_Other/00_ALU/ALU/02_add.v"
`include "/home/p0975633233/00_Other/00_ALU/ALU/03_normalize.v"
`include "/home/p0975633233/00_Other/00_ALU/ALU/04_round.v"
`include "/home/p0975633233/00_Other/00_ALU/ALU/05_pack.v"

module DP_pipe (
    input  op, clk, rst,
    input  [31:0] x0, x1, x2, x3, y0, y1, y2, y3,

    output [31:0] z
);
    //unpack
    wire upack_op;
    wire x0_s, x1_s, x2_s, x3_s, y0_s, y1_s, y2_s, y3_s;
    wire [7:0]  x0_e, x1_e, x2_e, x3_e, y0_e, y1_e, y2_e, y3_e;
    wire [11:0] x0_L, x0_H, x1_L, x1_H, x2_L, x2_H, x3_L, x3_H,
                y0_L, y0_H, y1_L, y1_H, y2_L, y2_H, y3_L, y3_H;

    unpack unpack(
        .op (op), 
        .x0 (x0), .x1 (x1), .x2 (x2), .x3 (x3), 
        .y0 (y0), .y1 (y1), .y2 (y2), .y3 (y3),     

        .unpack_op(unpack_op),
        .x0_s (x0_s), .x1_s (x1_s), .x2_s (x2_s), .x3_s (x3_s),
        .y0_s (y0_s), .y1_s (y1_s), .y2_s (y2_s), .y3_s (y3_s),     
        .x0_e (x0_e), .x1_e (x1_e), .x2_e (x2_e), .x3_e (x3_e),
        .y0_e (y0_e), .y1_e (y1_e), .y2_e (y2_e), .y3_e (y3_e),     
        .x0_L (x0_L), .x0_H (x0_H), .x1_L (x1_L), .x1_H (x1_H), 
        .x2_L (x2_L), .x2_H (x2_H), .x3_L (x3_L), .x3_H (x3_H),
        .y0_L (y0_L), .y0_H (y0_H), .y1_L (y1_L), .y1_H (y1_H),
        .y2_L (y2_L), .y2_H (y2_H), .y3_L (y3_L), .y3_H (y3_H)
    );

    // mul
    wire mul_op;
    wire r0_s, r1_s, r2_s, r3_s;
    wire [7:0] r_e;
    wire [7:0] sft_r0, sft_r1, sft_r2, sft_r3;
    wire [23:0] m0_0, m0_1, m0_2, m0_3,
                m1_0, m1_1, m1_2, m1_3,
                m2_0, m2_1, m2_2, m2_3,
                m3_0, m3_1, m3_2, m3_3;
    mul mul (
        .unpack_op(unpack_op),
        .x0_s (x0_s), .x1_s (x1_s), .x2_s (x2_s), .x3_s (x3_s),
        .y0_s (y0_s), .y1_s (y1_s), .y2_s (y2_s), .y3_s (y3_s),     
        .x0_e (x0_e), .x1_e (x1_e), .x2_e (x2_e), .x3_e (x3_e),
        .y0_e (y0_e), .y1_e (y1_e), .y2_e (y2_e), .y3_e (y3_e),

        .x0_L (x0_L), .x0_H (x0_H), .x1_L (x1_L), .x1_H (x1_H), 
        .x2_L (x2_L), .x2_H (x2_H), .x3_L (x3_L), .x3_H (x3_H),
        .y0_L (y0_L), .y0_H (y0_H), .y1_L (y1_L), .y1_H (y1_H),
        .y2_L (y2_L), .y2_H (y2_H), .y3_L (y3_L), .y3_H (y3_H),

        .mul_op(mul_op),
        .r0_s (r0_s), .r1_s (r1_s), .r2_s (r2_s), .r3_s (r3_s),

        .r_e (r_e),
        .sft_r0(sft_r0), .sft_r1(sft_r1), .sft_r2(sft_r2), .sft_r3(sft_r3),     
        .m0_0(m0_0), .m0_1(m0_1), .m0_2(m0_2), .m0_3(m0_3),
        .m1_0(m1_0), .m1_1(m1_1), .m1_2(m1_2), .m1_3(m1_3),
        .m2_0(m2_0), .m2_1(m2_1), .m2_2(m2_2), .m2_3(m2_3),
        .m3_0(m3_0), .m3_1(m3_1), .m3_2(m3_2), .m3_3(m3_3)
    );

    // add
    wire               add_op;
    wire               add_s;
    wire        [ 7:0] add_e;
    wire signed [49:0] add_m;
    add add (
        .mul_op(mul_op),
        .r0_s  (r0_s), .r1_s  (r1_s), .r2_s  (r2_s), .r3_s  (r3_s),
        .r_e   (r_e),
        .sft_r0(sft_r0), .sft_r1(sft_r1), .sft_r2(sft_r2), .sft_r3(sft_r3),     
        .m0_0(m0_0), .m0_1(m0_1), .m0_2(m0_2), .m0_3(m0_3),
        .m1_0(m1_0), .m1_1(m1_1), .m1_2(m1_2), .m1_3(m1_3),
        .m2_0(m2_0), .m2_1(m2_1), .m2_2(m2_2), .m2_3(m2_3),
        .m3_0(m3_0), .m3_1(m3_1), .m3_2(m3_2), .m3_3(m3_3),

        .add_op(add_op),
        .add_s (add_s),
        .add_e (add_e),
        .add_m (add_m)
    );

    // normalize
    wire               nor_op;
    wire               nor_s;
    wire        [ 7:0] nor_e;
    wire        [49:0] nor_m;
    normalize normalize (
        .add_op(add_op),
        .add_s (add_s),
        .add_e (add_e),
        .add_m (add_m),     

        .nor_op(nor_op),
        .nor_s (nor_s),
        .nor_e (nor_e),
        .nor_m (nor_m)
    );

    // round
    wire               rnd_op;
    wire               rnd_s;
    wire        [ 7:0] rnd_e;
    wire        [22:0] rnd_m;
    round round (
        .nor_op(nor_op),
        .nor_s (nor_s),
        .nor_e (nor_e),
        .nor_m (nor_m),    

        .rnd_op(rnd_op),
        .rnd_s (rnd_s),
        .rnd_e (rnd_e),
        .rnd_m (rnd_m)
    );

    pack pack (
        .rnd_op(rnd_op),
        .rnd_s (rnd_s),
        .rnd_e (rnd_e),
        .rnd_m (rnd_m),

        .z(z)
    );

    // =============
    // = pipe line =
    // =============
    // s1s2
    reg [23:0]
        m0_0_reg, m0_1_reg, m0_2_reg, m0_3_reg,
        m1_0_reg, m1_1_reg, m1_2_reg, m1_3_reg,
        m2_0_reg, m2_1_reg, m2_2_reg, m2_3_reg,
        m3_0_reg, m3_1_reg, m3_2_reg, m3_3_reg;
    reg mul_op_reg;
    reg r0_s_reg, r1_s_reg, r2_s_reg, r3_s_reg;
    reg [7:0] r_e_reg;
    reg [7:0] sft_r0_reg, sft_r1_reg, sft_r2_reg, sft_r3_reg;

    // s2s3
    reg                add_op_reg;
    reg                add_s_reg;
    reg         [ 7:0] add_e_reg;
    reg signed  [49:0] add_m_reg;

    // s3s4
    reg                nor_op_reg;
    reg                nor_s_reg;
    reg         [ 7:0] nor_e_reg;
    reg         [49:0] nor_m_reg;

    wire gclk = op & clk;

    // mul(S1) -> add(S2)
    always @(posedge gclk or negedge rst) begin
        if (rst) begin
          m0_1_reg <= 0;
          m0_2_reg <= 0;
          m0_3_reg <= 0;
          m1_1_reg <= 0;
          m1_2_reg <= 0;
          m1_3_reg <= 0;
          m2_1_reg <= 0;
          m2_2_reg <= 0;
          m2_3_reg <= 0;
          m3_1_reg <= 0;
          m3_2_reg <= 0;
          m3_3_reg <= 0;
        end
        else begin
          m0_1_reg <= m0_1;
          m0_2_reg <= m0_2;
          m0_3_reg <= m0_3;
          m1_1_reg <= m1_1;
          m1_2_reg <= m1_2;
          m1_3_reg <= m1_3;
          m2_1_reg <= m2_1;
          m2_2_reg <= m2_2;
          m2_3_reg <= m2_3;
          m3_1_reg <= m3_1;
          m3_2_reg <= m3_2;
          m3_3_reg <= m3_3;
        end
    end

    always @(posedge clk or negedge rst) begin
        if(rst) begin
            mul_op_reg <= 0;
            r0_s_reg   <= 0;
            r1_s_reg   <= 0;
            r2_s_reg   <= 0;
            r3_s_reg   <= 0;
            r_e_reg    <= 0;
            sft_r0_reg <= 0;
            sft_r1_reg <= 0;
            sft_r2_reg <= 0;
            sft_r3_reg <= 0;
            m0_0_reg<=0;
            m1_0_reg<=0;
            m2_0_reg<=0;
            m3_0_reg<=0;
        end
        else begin
            mul_op_reg <= mul_op;
            r0_s_reg   <= r0_s;
            r1_s_reg   <= r1_s;
            r2_s_reg   <= r2_s;
            r3_s_reg   <= r3_s;
            r_e_reg    <= r_e;
            sft_r0_reg <= sft_r0;
            sft_r1_reg <= sft_r1;
            sft_r2_reg <= sft_r2;
            sft_r3_reg <= sft_r3;
            m0_0_reg<=m0_0;
            m1_0_reg<=m1_0;
            m2_0_reg<=m2_0;
            m3_0_reg<=m3_0;
        end
    end

    // add(S2) -> normalize(S3)
    always @(posedge clk or negedge rst) begin
        if(rst)begin
            add_op_reg <= 0;
            add_s_reg  <= 0;
            add_e_reg  <= 0;
            add_m_reg  <= 0;
        end
        else begin
            add_op_reg <= add_op;
            add_s_reg  <= add_s;
            add_e_reg  <= add_e;
            add_m_reg  <= add_m;
        end
    end

    // normalize(S3) -> round(S4)
    always @(posedge clk or negedge rst) begin
        if(rst)begin
            nor_op_reg <= 0;
            nor_s_reg  <= 0;
            nor_e_reg  <= 0;
            nor_m_reg  <= 0;
        end
        else begin
            nor_op_reg <=nor_op;
            nor_s_reg  <=nor_s;
            nor_e_reg  <=nor_e;
            nor_m_reg  <=nor_m;
        end
    end
endmodule