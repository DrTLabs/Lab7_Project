// digit_mux.v - 4-to-1 Nibble Multiplexer
// Lab 7: TDM 7-Segment Display
//
// Selects one 4-bit nibble from the 16-bit switch input based on the
// current scan index. The selected nibble feeds into hex_to_7seg.
//
// Mapping:
//   idx=0 -> sw[ 3: 0]  (rightmost digit)
//   idx=1 -> sw[ 7: 4]
//   idx=2 -> sw[11: 8]
//   idx=3 -> sw[15:12]  (leftmost digit)

module digit_mux (
    input      [15:0] sw,
    input      [1:0]  idx,
    output reg [3:0]  digit
);

    always @(*) begin
        case (idx)
            2'd0: digit = sw[3:0];
            2'd1: digit = sw[7:4];
            // TODO: Complete the remaining two cases for idx=2 and idx=3
            default: digit = 4'h0;
        endcase
    end

endmodule
