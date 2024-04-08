module babbage_tb_user_input;

     // Control Inputs
     reg reset, clk, start;

     // Polynomial coefficients
     reg signed [1:0] a;
     reg signed [2:0] b;
     reg signed [3:0] c, d;
     reg signed [5:0] f;
     reg signed [9:0] g;

     // Evaluation number
     reg [6:0] n;

     wire signed [31:0] babbage_out;
     wire ready, done_tick;

     // Testbench-related parameters, variables and files
     parameter period = 20;
     parameter fileout = "babbage_results.txt";
     reg signed [31:0] expected_babbage;
     integer i, file;
     reg error;
     integer total_errors = 0;

     // Sign-extended polynomial coefficients
     reg signed [31:0] a_ext, b_ext, c_ext, d_ext, f_ext, g_ext;

     // Sign-extended evaluation number
     reg signed [31:0] n_ext;

     // Design Under test (DUT)
     babbage_top DUT (reset, clk, start, a, b, c, d, f, g, n, ready, babbage_out, done_tick);

     // Clock generation
     initial begin
          clk = 0;
          forever begin
               #(0.5*period) clk = ~clk;
          end
     end

     initial begin
          $dumpfile("dump.vcd");
          $dumpvars;
          file = $fopen(fileout, "w");
          $display("Beginning test...\n");
          $fwrite(file, "Beginning test...\n\n");
          i <= 0;
          error <= 1'b0;
          start <= 0;
          reset <= 0;
          #(4*period + 1); // Small additional delay to show reset is truly asynchronous!
          reset <= 1;
          expected_babbage <= 0;
          #(0.25*period);
          if (expected_babbage != babbage_out) begin 
               $display("$0t, Error in reset test");
               $fwrite(file, "$0t, Error in reset test\n");
               total_errors <= total_errors + 1;
               error <= 1'bx;
          end
          else begin
               error <= 1'b0;
               $display("Reset test passed!\n");
               $fwrite(file, "Reset test passed!\n");
          end
          reset <= 0;
          $display("Iterations tests following...");
          $fwrite(file, "Iterations tests following...\n\n");
          $display("Testing procedure is as follows:");
          $fwrite(file, "Testing procedure is as follows:\n");
          $display("Evaluate a polynomial u(n) = a n^5 + b n^4 + c n^3 + d n^2 + f n + g,");
          $fwrite(file, "Evaluate a polynomial u(n) = a·n^5 + b·n^4 + c·n^3 + d·n^2 + f·n + g,\n");
          $display("once using the Babbage Difference Engine (DUT), and once using the multiplication method as the unit test");
          $fwrite(file, "once using the Babbage Difference Engine (DUT), and once using the multiplication method as the unit test\n");
          $display("Inputs: n (integer larger than or equal to 0)");
          $fwrite(file, "Inputs: n (integer larger than or equal to 0)\n");
          $display("Coefficients: a, b, c, d, f, g (all signed integers)");
          $fwrite(file, "Coefficients: a, b, c, d, f, g (all signed integers)\n");
          $display("Bit lengths for all these can be changed, but for a proper 32-bit integer result");
          $fwrite(file, "Bit lengths for all these can be changed, but for a proper 32-bit integer result\n");
          $display("we have set a -> 2-bit, b -> 3-bit, c -> 4-bit, d -> 4-bit, f -> 6-bit, g -> 10 bit, n -> 7-bit");
          $fwrite(file, "we have set a -> 2-bit, b -> 3-bit, c -> 4-bit, d -> 4-bit, f -> 6-bit, g -> 10 bit, n -> 7-bit\n");
          $display("and then sign extended so that there is no chance of overflow in the result for any of these values.");
          $fwrite(file, "and then sign extended so that there is no chance of overflow in the result for any of these values.\n");
          $display("Modifications are possible of course, but do so accordingly for accurate results for any of these values.\n");
          $fwrite(file, "Modifications are possible of course, but do so accordingly for accurate results for any of these values.\n\n");
          #(period);
          a <= 2'b11;               // Fill the value of coefficient a in binary
          b <= 3'b010;              // Fill the value of coefficient b in binary
          c <= 4'b0101;             // Fill the value of coefficient c in binary
          d <= 4'b0111;             // Fill the value of coefficient d in binary
          f <= 6'b011101;           // Fill the value of coefficient f in binary
          g <= 10'b0011011011;      // Fill the value of coefficient g in binary
          n <= 7'b0110110;          // Fill the value of evalutation number n in binary
          #(period);
          a_ext <= {{30{a[1]}}, a};   // Sign-extend a to 32 bits
          b_ext <= {{29{b[2]}}, b};   // Sign-extend b to 32 bits
          c_ext <= {{28{c[3]}}, c};   // Sign-extend c to 32 bits
          d_ext <= {{28{d[3]}}, d};   // Sign-extend d to 32 bits
          f_ext <= {{26{f[5]}}, f};   // Sign-extend f to 32 bits
          g_ext <= {{22{g[9]}}, g};   // Sign-extend g to 32 bits
          n_ext <= {{22{1'b0}}, n};   // Extend n to 32 bits
          #(period);
          start <= 1;
          #(period);
          start <= 0;
          #(period);
          expected_babbage <= $signed(a_ext * (n_ext ** 5) + b_ext * (n_ext ** 4) + c_ext * (n_ext ** 3) + d_ext * (n_ext ** 2) + f_ext * n_ext + g_ext);
          $fwrite(file, "==============================================\n");
          $fwrite(file, "Iteration 1:\n");
          $fwrite(file, "a = %d\n", a);
          $fwrite(file, "b = %d\n", b);
          $fwrite(file, "c = %d\n", c);
          $fwrite(file, "d = %d\n", d);
          $fwrite(file, "f = %d\n", f);
          $fwrite(file, "g = %d\n", g);
          wait (done_tick == 1) begin
               #(3*period);
               if (expected_babbage != babbage_out) begin
                    $fwrite(file, "Error in test babbage_out = %d, expected babbage_out=%d\n", babbage_out, expected_babbage);
                    $display("$0t, Error in test babbage_out = %d ", babbage_out);
                    $display("$0t, expected babbage_out = %d", expected_babbage);
                    total_errors <= total_errors + 1;
                    error <= 1'bx;
               end
               else begin
                    $fwrite(file, "Expected: %d\n", expected_babbage);
                    $fwrite(file, "Test babbage_out = %d passed!\n", babbage_out);
                    error <= 1'b0;
               end
          end
          $fwrite(file, "==============================================\n\n");
          $display("Finished with %0d errors", total_errors);
          $fwrite(file, "\nFinished with %0d errors", total_errors);
          $fclose(file);
          $finish;
     end

endmodule