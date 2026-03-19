// tdm_scan.v - 2-bit Scan Index Counter
// Lab 7: TDM 7-Segment Display
//
// A 2-bit counter that cycles 0 -> 1 -> 2 -> 3 -> 0, advancing only
// when the clock-enable (CE) is asserted. Provides the digit selection
// index for the anode decoder and digit mux.
//
// Status: PROVIDED COMPLETE - do not modify

module tdm_scan (
    input            clk,
    input            rst,
    input            ce,
    output reg [1:0] idx
);

    always @(posedge clk) begin
        if (rst)
            idx <= 2'b00;
        else if (ce)
            idx <= idx + 2'd1;
    end

endmodule
