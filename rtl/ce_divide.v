// ce_divide.v - Parameterized Clock Enable Divider
// Lab 7: TDM 7-Segment Display
//
// Down-counter that generates a one-cycle clock-enable (CE) pulse every
// VAL clock cycles. The CE drives the TDM scan controller.
//
// Parameters:
//   VAL - Division value (default 250_000). CE frequency:
//         f_tick = 100 MHz / VAL,  f_digit = f_tick / 4
//
// Ports:
//   clk  - System clock
//   rst  - Synchronous reset (loads counter to VAL-1)
//   load - When high, loads (d-1) into the counter
//   d    - Value to load (counter will count down from d-1)
//   ce   - One-cycle clock-enable pulse (high when count reaches 0)
//
// Status: PROVIDED COMPLETE - do not modify

`timescale 1ns/1ps
`default_nettype none   // undeclared names are errors, not silent 1-bit wires

module ce_divide #(
    parameter VAL = 250_000
)(
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    load,
    input  wire [$clog2(VAL)-1:0]  d,
    output wire                    ce
);

    reg [$clog2(VAL)-1:0] count;

    assign ce = (count == 0);

    always @(posedge clk) begin
        if (rst)
            count <= VAL - 1;
        else if (load)
            count <= d - 1;
        else if (count == 0)
            count <= VAL - 1;
        else
            count <= count - 1;
    end

endmodule
