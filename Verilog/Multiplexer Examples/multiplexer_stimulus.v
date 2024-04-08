module multiplexer_stimulus;
     reg a, b, c, d;
     reg [1:0] sel;
     wire y;

     integer total_errors=0, i;
     reg expected, error;

     multiplexer_assign DUT (a, b, c, d, sel, y);

     initial begin
          error=1'b0;
          for (i=0; i<64; i=i+1) begin
               a = i[5];
               b = i[4];
               c = i[3];
               d = i[2];
               sel = i[1:0];
               expected = (a & ~sel[1] & ~sel[0]) | (b & ~sel[1] & sel[0]) | (c & sel[1] & ~sel[0]) | (d & sel[1] & sel[0]);
               #(10)
               if (expected !== y) begin 
                    $display("$0t, Error in test a = %b, b = %b, c = %b, d = %b, sel = %b", a, b, c, d, sel);
                    total_errors = total_errors + 1;
                    error = 1'bx;
               end
               else error = 1'b0;
          end
          $display("Finished with %0d errors", total_errors);
     end

endmodule
