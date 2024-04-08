module babbage_fpga_interface (reset, clk, start, small_dip, big_dip, ready, babbage_out_trunc, done_tick);

     // Control I/O
     input reset, clk, start;
     input [2:0] small_dip;
     input [7:0] big_dip;

     // Polynomial coefficients
     reg signed [1:0] a;
     reg signed [2:0] b;
     reg signed [3:0] c, d;
     reg signed [5:0] f;
     reg signed [9:0] g;

     // Evaluation number
     reg [6:0] n;

     wire signed [31:0] babbage_out;
     output ready, done_tick;

     wire [9:0] babbage_out_trunc;

     // Clock divider
     clock_divider dived (reset, clk, clk_div);

     always @(posedge clk_div or posedge reset) begin
          if (reset) begin
               a <= 0;
               b <= 0;
               c <= 0;
               d <= 0;
               f <= 0;
               g <= 0;
               n <= 0;
          end
          else begin
               case (small_dip) begin
                    3'b000: a <= big_dip[1:0];
                    3'b001: b <= big_dip[2:0];
                    3'b011: c <= big_dip[3:0];
                    3'b010: d <= big_dip[3:0];
                    3'b110: f <= big_dip[5:0];
                    3'b100: g <= {big_dip[7], 2'b0, big_dip[6:0]};
                    3'b101: n <= big_dip[6:0];
               endcase
          end
     end

     // Top module
     babbage_top top_module (reset, clk_div, start, a, b, c, d, f, g, n, ready, babbage_out, done_tick);

     assign babbage_out_trunc = {babbage_out[31], babbage_out[8:0]};

endmodule