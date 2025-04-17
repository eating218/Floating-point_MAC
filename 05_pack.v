module pack (
    input        rnd_op,
    input        rnd_s,
    input [ 7:0] rnd_e,
    input [22:0] rnd_m,

    output reg [31:0] z
);

  // op = 0:半精、1:單精
  always @(*) begin
    case (rnd_op)
      0: begin
        z = {16'd0, rnd_s, rnd_e[4:0], rnd_m[9:0]};
      end
      1: begin
        z = {rnd_s, rnd_e, rnd_m};
      end
    endcase
  end

endmodule