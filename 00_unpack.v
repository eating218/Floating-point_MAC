module unpack (
    input             op,
    input      [31:0] x0, x1, x2, x3, y0, y1, y2, y3,
    
    output            unpack_op,
    output reg        x0_s, x1_s, x2_s, x3_s, y0_s, y1_s, y2_s, y3_s,
    output reg [ 7:0] x0_e, x1_e, x2_e, x3_e, y0_e, y1_e, y2_e, y3_e,
    output reg [11:0] x0_L, x0_H, x1_L, x1_H, x2_L, x2_H, x3_L, x3_H, 
                      y0_L, y0_H, y1_L, y1_H, y2_L, y2_H, y3_L, y3_H
  );

  reg [22:0] x0_m, x1_m, x2_m, x3_m, y0_m, y1_m, y2_m, y3_m;

  // op = 0:半精、1:單精
  assign unpack_op = op;

  always @(*) begin
    case (op)
      0://half-precision 1||5||10
      begin
        {x0_s, x1_s, x2_s, x3_s, y0_s, y1_s, y2_s, y3_s} = {
          x0[15], x1[15], x2[15], x3[15], y0[15], y1[15], y2[15], y3[15]
        };
        {x0_e, x1_e, x2_e, x3_e, y0_e, y1_e, y2_e, y3_e} = {
          {3'd0, x0[14:10]}, {3'd0, x1[14:10]}, {3'd0, x2[14:10]}, {3'd0, x3[14:10]},
          {3'd0, y0[14:10]}, {3'd0, y1[14:10]}, {3'd0, y2[14:10]}, {3'd0, y3[14:10]}
        };
        {x0_m, x1_m, x2_m, x3_m, y0_m, y1_m, y2_m, y3_m} = {
          {13'd0, x0[9:0]}, {13'd0, x1[9:0]}, {13'd0, x2[9:0]}, {13'd0, x3[9:0]},
          {13'd0, y0[9:0]}, {13'd0, y1[9:0]}, {13'd0, y2[9:0]}, {13'd0, y3[9:0]}
        };
      end
      1://single-precision
      begin
        {x0_s, x1_s, x2_s, x3_s, y0_s, y1_s, y2_s, y3_s} = {
          x0[31], x1[31], x2[31], x3[31], y0[31], y1[31], y2[31], y3[31]
        };
        {x0_e, x1_e, x2_e, x3_e, y0_e, y1_e, y2_e, y3_e} = {
          x0[30:23], x1[30:23], x2[30:23], x3[30:23], 
          y0[30:23], y1[30:23], y2[30:23], y3[30:23]
        };
        {x0_m, x1_m, x2_m, x3_m, y0_m, y1_m, y2_m, y3_m} = {
          x0[22:0], x1[22:0], x2[22:0], x3[22:0], 
          y0[22:0], y1[22:0], y2[22:0], y3[22:0]
        };
      end
    endcase
  end
  always @(*) begin
    // High bits
    x0_H = {1'b1, x0_m[22:12]};
    x1_H = {1'b1, x1_m[22:12]};
    x2_H = {1'b1, x2_m[22:12]};
    x3_H = {1'b1, x3_m[22:12]};

    y0_H = {1'b1, y0_m[22:12]};
    y1_H = {1'b1, y1_m[22:12]};
    y2_H = {1'b1, y2_m[22:12]};
    y3_H = {1'b1, y3_m[22:12]};

    // Low bits
    x0_L = (!op)? {2'b01, x0_m[9:0]} : x0_m[11:0];
    x1_L = (!op)? {2'b01, x1_m[9:0]} : x1_m[11:0];
    x2_L = (!op)? {2'b01, x2_m[9:0]} : x2_m[11:0];
    x3_L = (!op)? {2'b01, x3_m[9:0]} : x3_m[11:0];

    y0_L = (!op)? {2'b01, y0_m[9:0]} : y0_m[11:0];
    y1_L = (!op)? {2'b01, y1_m[9:0]} : y1_m[11:0];
    y2_L = (!op)? {2'b01, y2_m[9:0]} : y2_m[11:0];
    y3_L = (!op)? {2'b01, y3_m[9:0]} : y3_m[11:0];
  end
endmodule