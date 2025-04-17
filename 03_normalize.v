module normalize (
    input        add_op,
    input        add_s,
    input [ 7:0] add_e,
    input [49:0] add_m,

    output            nor_op,
    output reg        nor_s,
    output reg [ 7:0] nor_e,
    output reg [49:0] nor_m
 );

  // hidden one index of half-precision = 0 + 20   Q3.20
  // hidden one index of single-precision = 0 + 46 Q4.46

  integer i;
  reg     count;
  reg [5:0] index, hid_one_index;
  reg [5:0] exp_diff;

  // op = 0:半精、1:單精
  assign nor_op = add_op;

  //normalize shift
  always @(*) begin
    //hidden 1 & leading 1
    index = 0;
    count = 0;
    for (i = 49; i >= 0 && !count; i = i - 1) begin
      index = (add_m[i]) ? i : 0;
      count = (add_m[i]);
    end
  end

  always @(*) begin
    hid_one_index = (add_op)? 46 : 20;

    //nor_e & nor_m
    if (index > hid_one_index)      // 右移
    begin
      exp_diff = (index - hid_one_index);
      nor_m = add_m >> exp_diff;
      nor_e = add_e + exp_diff;
    end
    else if (index < hid_one_index) // 左移
    begin
      exp_diff = (hid_one_index - index);
      nor_m = add_m << exp_diff;
      nor_e = add_e - exp_diff;
    end
    else 
    begin
      exp_diff = 0;
      nor_m = add_m;
      nor_e = add_e;
    end
    nor_s = add_s;
  end
endmodule