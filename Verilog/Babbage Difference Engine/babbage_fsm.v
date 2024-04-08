module babbage_fsm (reset, clk, start, done, ready, precalc_enable_1, precalc_enable_2, calc_enable, done_tick);
     localparam IDLE = 3'b000, PRECALC1 = 3'b001, PRECALC2 = 3'b011, CALC = 3'b010, DONE = 3'b110, BUFFER = 3'b100;

     input reset, clk, start, done;
     output reg ready, precalc_enable_1, precalc_enable_2, calc_enable, done_tick;

     reg [2:0] state, next;

     // Sequential always block for the state register
     always @(posedge clk or posedge reset) begin
          if (reset) state <= 3'b000;
          else state <= next;
     end

     // Combinational always block, so we'll use
     // blocking statements here
     always @(*) begin
          ready = 1'b0;
          next = 2'bx;
          case (state)
               IDLE:
               begin
                    calc_enable = 1'b0;
                    precalc_enable_1 = 1'b0;
                    precalc_enable_2 = 1'b0;
                    done_tick = 1'b0;
                    if (start) next = PRECALC1;
                    else begin
                         ready = 1'b1;
                         next = IDLE;
                    end
               end
               PRECALC1:
               begin
                    precalc_enable_1 = 1'b1;
                    precalc_enable_2 = 1'b0;
                    next = PRECALC2;
               end
               PRECALC2:
               begin
                    precalc_enable_1 = 1'b0;
                    precalc_enable_2 = 1'b1;
                    next = CALC;
               end
               CALC:
               begin
                    precalc_enable_2 = 1'b0;
                    calc_enable = 1'b1;
                    if (done) next = DONE;
                    else next = CALC;
               end
               DONE:
               begin
                    done_tick = 1'b1;
                    next = BUFFER;
               end
               BUFFER:
               begin
                    done_tick = 1'b1;
                    next = IDLE;
               end
          endcase
     end

endmodule