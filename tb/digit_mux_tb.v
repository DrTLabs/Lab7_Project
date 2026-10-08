//============================================================================
// Testbench: Digit Multiplexer
//
// Self-checking testbench that verifies all four index selections for two
// different switch values:
//   idx=0 selects sw[ 3: 0]  (rightmost digit)
//   idx=1 selects sw[ 7: 4]
//   idx=2 selects sw[11: 8]
//   idx=3 selects sw[15:12]  (leftmost digit)
//
// Status: PROVIDED COMPLETE - do not modify
//============================================================================

`timescale 1ns/1ps

module digit_mux_tb;

    //------------------------------------------------------------------------
    // Signal Declarations
    //------------------------------------------------------------------------
    reg  [15:0] sw;
    reg  [1:0]  idx;
    wire [3:0]  digit;

    // Expected output
    reg  [3:0]  expected_digit;

    // Error tracking
    integer error_count;

    //------------------------------------------------------------------------
    // Unit Under Test (UUT)
    //------------------------------------------------------------------------
    digit_mux UUT (
        .sw(sw),
        .idx(idx),
        .digit(digit)
    );

    //------------------------------------------------------------------------
    // Test Stimulus
    //------------------------------------------------------------------------
    initial begin
        error_count = 0;

        $display("================================================");
        $display("Digit Multiplexer Testbench");
        $display("================================================");
        $display("  sw   | idx | digit | Expected | Status");
        $display("-------+-----+-------+----------+-------");

        // Every nibble is different, so a wrong slice cannot pass by accident
        sw = 16'h1234;
        idx = 2'd0; expected_digit = 4'h4; #10; check_output();
        idx = 2'd1; expected_digit = 4'h3; #10; check_output();
        idx = 2'd2; expected_digit = 4'h2; #10; check_output();
        idx = 2'd3; expected_digit = 4'h1; #10; check_output();

        sw = 16'hABCD;
        idx = 2'd0; expected_digit = 4'hD; #10; check_output();
        idx = 2'd1; expected_digit = 4'hC; #10; check_output();
        idx = 2'd2; expected_digit = 4'hB; #10; check_output();
        idx = 2'd3; expected_digit = 4'hA; #10; check_output();

        // Results
        $display("================================================");
        if (error_count == 0) begin
            $display("TEST PASSED - All 8 selections correct!");
        end else begin
            $display("TEST FAILED - %0d errors found", error_count);
        end
        $display("================================================");

        if (error_count == 0)
            $finish(0);
        else
            $finish(1);
    end

    //------------------------------------------------------------------------
    // Output Checking Task
    //------------------------------------------------------------------------
    task check_output;
        begin
            if (digit !== expected_digit) begin
                $display("  %h |  %0d  |   %h   |    %h     | FAIL",
                         sw, idx, digit, expected_digit);
                error_count = error_count + 1;
            end else begin
                $display("  %h |  %0d  |   %h   |    %h     | ok",
                         sw, idx, digit, expected_digit);
            end
        end
    endtask

endmodule
