module multiplexer_always (a, b, c, d, sel, y);

     input a, b, c, d;
     input [1:0] sel;
     output reg y;

     always @(a or b or c or d or sel) begin
          if (sel == 2'b00) y <= a;
          else if (sel == 2'b01) y <= b;
          else if (sel == 2'b10) y <= c;
          else y <= d;
     end

endmodule