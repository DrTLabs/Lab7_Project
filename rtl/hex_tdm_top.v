// hex_tdm_top.v - TDM 7-Segment Display Top-Level Module
// Lab 7: TDM 7-Segment Display
//
// Integrates five submodules to create a time-division multiplexed
// hex display on the Basys3 board:
//   1. ce_divide    - Clock enable divider (CE every DIV_VAL clocks)
//   2. tdm_scan     - 2-bit scan index (cycles 0..3)
//   3. anode_decode - Active-low anode selection
//   4. digit_mux    - Nibble selection from switches
//   5. hex_to_7seg  - Hex-to-segment decoder
//
// Refer to the RTL diagram in Assets/ for signal flow.

`timescale 1ns/1ps
`default_nettype none   // undeclared names are errors, not silent 1-bit wires

module hex_tdm_top #(parameter DIV_VAL = 250_000) (
    input  wire        clk,
    input  wire        btnC,     // Center button = active-high reset
    input  wire [15:0] sw,
    output wire [6:0]  seg,
    output wire [3:0]  an
);

    // Map board button to internal reset for readability
    wire rst;
    assign rst = btnC;

    // TODO #1: Declare internal wires
    //   - wire         ce;     // clock-enable from ce_divide
    //   - wire [1:0]   idx;    // current digit index from tdm_scan
    //   - wire [3:0]   digit;  // selected nibble from digit_mux

    // TODO #2: Instantiate ce_divide
    //   ce_divide #(.VAL(DIV_VAL)) u_div (
    //       .clk(clk), .rst(rst), .load(1'b0), .d({$clog2(DIV_VAL){1'b0}}), .ce(ce)
    //   );

    // TODO #3: Instantiate tdm_scan
    //   Connect clk, rst, ce as inputs; idx as output

    // TODO #4: Instantiate anode_decode
    //   Connect idx as input; an as output

    // TODO #5: Instantiate digit_mux
    //   Connect sw and idx as inputs; digit as output

    // TODO #6: Instantiate hex_to_7seg
    //   Connect digit as input (to hex port); seg as output

endmodule
