module round (
    input        nor_op,
    input        nor_s,
    input [ 7:0] nor_e,
    input [49:0] nor_m,

    output reg        rnd_op,
    output reg        rnd_s,
    output reg [ 7:0] rnd_e,
    output reg [22:0] rnd_m
 );

  reg round;
  reg [23:0] rnd_temp;

  // op = 0:半精、1:單精
  // 1x:看x決定、0x:若x == 1 && 後面不為 0 則進位
  always @(*) begin
    if (!nor_op)
    begin
      case (nor_m[10])
        0: round = nor_m[9] & (|nor_m[8:0]);
        1: round = nor_m[9];
      endcase

      rnd_temp = nor_m[19:10] + round;
      rnd_e = nor_e + rnd_temp[10];
      rnd_m = (rnd_temp[10])? rnd_temp[10:1] : rnd_temp[9:0];
    end
    else
    begin
      case (nor_m[23])
        0: round = nor_m[22] & (|nor_m[21:0]);
        1: round = nor_m[22];
      endcase

      rnd_temp = nor_m[45:23] + round;
      rnd_e = nor_e + rnd_temp[23];
      rnd_m = (rnd_temp[23])? rnd_temp[23:1] : rnd_temp[22:0];
    end

    rnd_op = nor_op;
    rnd_s  = nor_s;
  end
endmodule