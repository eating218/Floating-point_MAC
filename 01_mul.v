module mul (
    input        unpack_op,
    input        x0_s, x1_s, x2_s, x3_s, y0_s, y1_s, y2_s, y3_s,
    input [ 7:0] x0_e, x1_e, x2_e, x3_e, y0_e, y1_e, y2_e, y3_e,
    input [11:0] x0_L, x0_H, x1_L, x1_H, x2_L, x2_H, x3_L, x3_H, 
                 y0_L, y0_H, y1_L, y1_H, y2_L, y2_H, y3_L, y3_H,

    output             mul_op,
    output reg         r0_s, r1_s, r2_s, r3_s,
    output reg  [ 7:0] r_e,
    output reg  [ 7:0] sft_r0, sft_r1, sft_r2, sft_r3,
    output  reg [23:0] m0_0, m0_1, m0_2, m0_3,
                       m1_0, m1_1, m1_2, m1_3,
                       m2_0, m2_1, m2_2, m2_3,
                       m3_0, m3_1, m3_2, m3_3
  );
  
  // op = 0:半精、1:單精
  reg [7:0] temp_e1, temp_e2;
  reg [7:0] r0_e, r1_e, r2_e, r3_e;
  reg [6:0] exp_offset;
  reg [11:0] t0, t4, t1, t5, t2, t6, t3, t7, t8, t12, t9 ,t13,t10,t14,t11,t15,t16,t20,t17,t21,t18,t22,t19,t23,t24,t28,t25,t29,t26,t30,t27,t31;
  assign mul_op = unpack_op;


  //sign
  always @(*) begin
    {r0_s, r1_s, r2_s, r3_s} = {x0_s ^ y0_s, x1_s ^ y1_s, x2_s ^ y2_s, x3_s ^ y3_s};
  end

  //max_exp
  always @(*) begin
    exp_offset = (unpack_op)? 7'd127 : 7'd15;
    
    {r0_e, r1_e, r2_e, r3_e} = {
      x0_e + y0_e - exp_offset,
      x1_e + y1_e - exp_offset,
      x2_e + y2_e - exp_offset,
      x3_e + y3_e - exp_offset
    };

    temp_e1 = (r0_e > r1_e)? r0_e : r1_e;
    temp_e2 = (r2_e > r3_e)? r2_e : r3_e;

    r_e = (temp_e1 > temp_e2)? temp_e1 : temp_e2;
  end

  //shfit amount of exp
  always @(*) begin
    sft_r0 = r_e - r0_e;
    sft_r1 = r_e - r1_e;
    sft_r2 = r_e - r2_e;
    sft_r3 = r_e - r3_e;
  end

  parameter type = 0;
    generate
      case (type)
        1: begin
          always @(*) begin//non-gated
            t0=x0_L;  t4=y0_L;
            t1=x1_L;  t5=y1_L;
            t2=x2_L;  t6=y2_L;
            t3=x3_L;  t7=y3_L;

            t8 =x0_L; t12=y0_H;
            t9 =x1_L; t13=y1_H;
            t10=x2_L; t14=y2_H;
            t11=x3_L; t15=y3_H;  

            t16=x0_H; t20=y0_L;
            t17=x1_H; t21=y1_L;
            t18=x2_H; t22=y2_L;
            t19=x3_H; t23=y3_L;

            t24=x0_H; t28=y0_H;
            t25=x1_H; t29=y1_H;
            t26=x2_H; t30=y2_H;
            t27=x3_H; t31=y3_H;
            end
        end
        0: begin
          always @(*) begin
            t0=x0_L; t4=y0_L;
            t1=x1_L; t5=y1_L;
            t2=x2_L; t6=y2_L;
            t3=x3_L; t7=y3_L;

            if(unpack_op)begin //latch gated
              t8 =x0_L; t12=y0_H;
              t9 =x1_L; t13=y1_H;
              t10=x2_L; t14=y2_H;
              t11=x3_L; t15=y3_H;  
 
              t16=x0_H; t20=y0_L;
              t17=x1_H; t21=y1_L;
              t18=x2_H; t22=y2_L;
              t19=x3_H; t23=y3_L;
 
              t24=x0_H; t28=y0_H;
              t25=x1_H; t29=y1_H;
              t26=x2_H; t30=y2_H;
              t27=x3_H; t31=y3_H;
            end
          end
        end
      endcase
    endgenerate

  always @(*) begin
    m0_0 =t0 * t4;
    m1_0 =t1 * t5;
    m2_0 =t2 * t6;
    m3_0 =t3 * t7;    //LSB L*L

    m0_1 =t8  * t12;
    m1_1 =t9  * t13;
    m2_1 =t10 * t14;
    m3_1 =t11 * t15;  //mid L*H

    m0_2 =t16 * t20;
    m1_2 =t17 * t21;
    m2_2 =t18 * t22;
    m3_2 =t19 * t23;  //mid H*L

    m0_3 =t24 * t28;
    m1_3 =t25 * t29;
    m2_3 =t26 * t30;
    m3_3 =t27 * t31;  //MSB H*H
  end
endmodule