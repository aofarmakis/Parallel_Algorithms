module multiplexer_gates (a, b, c, d, sel, y);

     input a, b, c, d;
     input [1:0] sel;
     output y;

     wire ns0, ns1, w0, w1, w2, w3;

     not(ns0, sel[0]);
     not(ns1, sel[1]);

     and(w0, ns1, ns0, a);
     and(w1, ns1, sel[0], b);
     and(w2, sel[1], ns0, c);
     and(w3, sel[1], sel[0], d);

     or(y, w0, w1, w2, w3);

endmodule