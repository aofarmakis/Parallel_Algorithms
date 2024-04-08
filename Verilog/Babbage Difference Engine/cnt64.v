module cnt64 (reset, clk, enable, clkdiv64);
     input reset, clk, enable;
     output clkdiv64;
     reg [5:0] cnt;

     assign clkdiv64 = (cnt==6'd63);
     always @(posedge reset or posedge clk)
          if (reset) cnt <= 0;
          else if (enable) cnt <= cnt + 1;

endmodule
