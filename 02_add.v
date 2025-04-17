module add (
    input        mul_op,
    input        r0_s, r1_s, r2_s, r3_s,
    input [ 7:0] r_e,
    input [ 7:0] sft_r0, sft_r1, sft_r2, sft_r3,
    input [23:0] m0_0, m0_1, m0_2, m0_3,
                 m1_0, m1_1, m1_2, m1_3,
                 m2_0, m2_1, m2_2, m2_3,
                 m3_0, m3_1, m3_2, m3_3,

    output                   add_op,
    output reg               add_s,
    output reg        [ 7:0] add_e,
    output reg signed [49:0] add_m
 );

  // op = 0:半精、1:單精
  assign add_op = mul_op;
  reg [47:0] add_temp0, add_temp1, add_temp2, add_temp3, r0_m, r1_m, r2_m, r3_m;
  reg signed [48:0] s_r0_m, s_r1_m, s_r2_m, s_r3_m;         //{1 bit sign bit, 48 bits}
  reg signed [48:0] sft_r0_m, sft_r1_m, sft_r2_m, sft_r3_m;
  reg signed [49:0] sft_temp0, sft_temp1;
  reg signed [50:0] res;                                    //{進位  2 bit, 49 bits}

  // 加法
  always @(*) begin
      add_temp0 = (mul_op)? {12'd0, m0_1, 12'd0} + {12'd0, m0_2, 12'd0} + {m0_3, 24'd0} : 0;
      add_temp1 = (mul_op)? {12'd0, m1_1, 12'd0} + {12'd0, m1_2, 12'd0} + {m1_3, 24'd0} : 0;
      add_temp2 = (mul_op)? {12'd0, m2_1, 12'd0} + {12'd0, m2_2, 12'd0} + {m2_3, 24'd0} : 0;
      add_temp3 = (mul_op)? {12'd0, m3_1, 12'd0} + {12'd0, m3_2, 12'd0} + {m3_3, 24'd0} : 0;

      // half-precision的話，除了L*L乘法器外的乘法結果都不用加
      r0_m = {24'd0, m0_0} + add_temp0;
      r1_m = {24'd0, m1_0} + add_temp1;
      r2_m = {24'd0, m2_0} + add_temp2;
      r3_m = {24'd0, m3_0} + add_temp3; 
  end

  // 負數轉成2補數
  always @(*) begin
    //unsigned to signed
    if (mul_op) begin // single
      s_r0_m = (r0_s) ? -r0_m : r0_m;
      s_r1_m = (r1_s) ? -r1_m : r1_m;
      s_r2_m = (r2_s) ? -r2_m : r2_m;
      s_r3_m = (r3_s) ? -r3_m : r3_m;
    end else begin    // half
      s_r0_m = (r0_s) ? -{27'd0, r0_m} : {27'd0, r0_m};
      s_r1_m = (r1_s) ? -{27'd0, r1_m} : {27'd0, r1_m};
      s_r2_m = (r2_s) ? -{27'd0, r2_m} : {27'd0, r2_m};
      s_r3_m = (r3_s) ? -{27'd0, r3_m} : {27'd0, r3_m};
    end

    //shift
    sft_r0_m = s_r0_m >>> sft_r0;
    sft_r1_m = s_r1_m >>> sft_r1;
    sft_r2_m = s_r2_m >>> sft_r2;
    sft_r3_m = s_r3_m >>> sft_r3;

    //add
    sft_temp0 = sft_r0_m + sft_r1_m;
    sft_temp1 = sft_r2_m + sft_r3_m;
    res = sft_temp0 + sft_temp1;

    //output
    add_s = res[50];
    add_e = r_e;
    add_m = (res[50])? -res[49:0] : res[49:0];

  end
endmodule