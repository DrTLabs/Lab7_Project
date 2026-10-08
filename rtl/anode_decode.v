// anode_decode.v - Active-Low Anode Decoder
// Lab 7: TDM 7-Segment Display
//
// Maps a 2-bit digit index to active-low one-hot anode outputs.
// Only one anode is driven low (ON) at a time; the rest are high (OFF).
//
// Truth Table:
//   idx | an[3:0] | Active Digit
//   ----+---------+-------------
//    0  |  1110   | Rightmost
//    1  |  1101   | Second
//    2  |  1011   | Third
//    3  |  0111   | Leftmost
//
// Hint: Model your solution after hex_to_7seg.v in the rtl/ directory
//       (use a combinational always @(*) with a case on idx).

`timescale 1ns/1ps
`default_nettype none   // undeclared names are errors, not silent 1-bit wires

module anode_decode (
    input  wire [1:0] idx,
    output reg  [3:0] an
);

    // TODO: Implement combinational active-low one-hot anode decode
    // Use an always @(*) block with a case statement on idx.
    // Map each index value to the correct anode pattern from the truth table above.
    // Include a default case that turns all anodes OFF (4'b1111).

endmodule
