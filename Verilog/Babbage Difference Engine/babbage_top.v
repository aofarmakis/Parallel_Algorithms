module babbage_top (reset, clk, start, a, b, c, d, f, g, n, ready, babbage_out, done_tick);

     // Control I/O
     input reset, clk, start;

     // Polynomial coefficients
     input signed [1:0] a;
     input signed [2:0] b;
     input signed [3:0] c, d;
     input signed [5:0] f;
     input signed [9:0] g;

     // Evaluation number
     input [6:0] n;

     output signed [31:0] babbage_out;
     output ready, done_tick;

     wire precalc_enable_1, precalc_enable_2, calc_enable, done;

     babbage_datapath datapath (reset, clk, ready, precalc_enable_1, precalc_enable_2, calc_enable, a, b, c, d, f, g, n, babbage_out, done);
     babbage_fsm control_fsm (reset, clk, start, done, ready, precalc_enable_1, precalc_enable_2, calc_enable, done_tick);

endmodule