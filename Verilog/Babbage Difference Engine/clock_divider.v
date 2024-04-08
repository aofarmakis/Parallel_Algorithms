module clock_divider (reset, clk, clk_div);
     input clk, reset;
     output clk_div;
     wire first, second;

     cnt64 c0 (reset, clk, 1'b1, first);
     cnt64 c1 (reset, clk, first, second);

     assign clk_div = first & second;

endmodule




