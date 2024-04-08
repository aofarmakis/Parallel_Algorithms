module babbage_datapath (reset, clk, ready, precalc_enable_1, precalc_enable_2, calc_enable, a, b, c, d, f, g, n, babbage_out, done);

     // Control I/O
     input reset, clk, ready, precalc_enable_1, precalc_enable_2, calc_enable;
     output done;

     // Polynomial coefficients
     input signed [1:0] a;
     input signed [2:0] b;
     input signed [3:0] c;
     input signed [3:0] d;
     input signed [5:0] f;
     input signed [9:0] g;

     // Evaluation number
     input [6:0] n;

     // Output polynomial evaluation
     output reg signed [31:0] babbage_out;

     // Piece-wise polynomials and intermediate registers
     reg signed [31:0] u, v, w, x, y, z;
     reg signed [31:0] u_precalc, v_precalc, w_precalc, x_precalc, y_precalc, z_precalc;

     // Evaluation number register (which will decrement to 0)
     reg [6:0] n_reg;

     // Initial computations for piece-wise polynomials based on polynomial coefficients
     wire signed [31:0] u_ini_comp, v_ini_comp, w_ini_comp, x_ini_comp, y_ini_comp, z_ini_comp;

     // Initial evaluations for u, v, w, x, y, z piece-wise polynomials.
     // Multiplications and such with given numbers are optimized during
     // synthesis, so no need to write this otherwise.
     // For example, you won't get a multiplier to get 120*a, you'll get
     // an adder scheme that takes 128*a and subtracts 8*a from it.
     // It will be the critical path as is, so here it is worth pipelining!
     // However, for simplicity’s sake, we will keep these as is as to highlight
     // the algorithm behind the Babbage Difference Engine.
     assign u_ini_comp = g;
     assign v_ini_comp = 5*a + (-10*a+4*b) + (10*a-6*b+3*c) + (-5*a+4*b-3*c+2*d) + (a-b+c-d+f);
     assign w_ini_comp = 20*a*8 + (-60*a+12*b)*4 + (70*a-24*b+6*c)*2 + (-30*a+14*b-6*c+2*d);
     assign x_ini_comp = 40*a*9 + (-120*a+24*b)*3 + (150*a-36*b+6*c);
     assign y_ini_comp = 120*a*4 + (-240*a+24*b);
     assign z_ini_comp = 120*a;

     // Save initial computations to precalc registers
     always @(posedge reset or posedge clk) begin
          if (reset) begin
               u_precalc <= 0;
               v_precalc <= 0;
               w_precalc <= 0;
               x_precalc <= 0;
               y_precalc <= 0;
               z_precalc <= 0;
               n_reg <= 0;
          end
          else if (precalc_enable_1) begin
               u_precalc <= u_ini_comp;
               v_precalc <= v_ini_comp;
               w_precalc <= w_ini_comp;
               x_precalc <= x_ini_comp;
               y_precalc <= y_ini_comp;
               z_precalc <= z_ini_comp;
               n_reg <= n;
          end
     end

     // Assignments made to accumulator registers for piece-wise polynomials
     // Babbage output and done control signal to FSM is below as well
     always @(posedge reset or posedge clk) begin
          if (reset) begin
               u <= 0;
               v <= 0;
               w <= 0;
               x <= 0;
               y <= 0;
               z <= 0;
               babbage_out <= 0;
          end
          else if (precalc_enable_1) begin
               u <= 0;
               v <= 0;
               w <= 0;
               x <= 0;
               y <= 0;
               z <= 0;
               babbage_out <= 0;
          end
          else if (precalc_enable_2) begin
               u <= u_precalc;
               v <= v_precalc;
               w <= w_precalc;
               x <= x_precalc;
               y <= y_precalc;
               z <= z_precalc;
          end
          else if (calc_enable) begin
               if (n_reg == 0) begin
                    n_reg <= 0;
                    babbage_out <= u;
               end
               else begin
                    n_reg <= n_reg - 1;
                    u <= u + v;
                    v <= v + w;
                    w <= w + x;
                    x <= x + y;
                    y <= y + z;
               end
          end
     end

     assign done = calc_enable & (n_reg == 0) & ~ready;

endmodule