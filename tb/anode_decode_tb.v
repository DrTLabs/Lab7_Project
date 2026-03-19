//============================================================================
// Testbench: Anode Decoder
//
// YOUR TASK: Complete the 2 sections marked with TODO
//
// The anode decoder maps a 2-bit index to active-low one-hot outputs:
//
// Truth Table:
//   idx | an[3:0] | Which digit is ON
//   ----+---------+------------------
//    0  |  1110   | Rightmost
//    1  |  1101   | Second from right
//    2  |  1011   | Third from right
//    3  |  0111   | Leftmost
//
// HINT: Study the halfadder_tb.v pattern from Lab 4 for reference.
//       This is a combinational module - no clock is needed.
//============================================================================

`timescale 1ns/1ps

module anode_decode_tb;

    //------------------------------------------------------------------------
    // Signal Declarations
    //------------------------------------------------------------------------
    reg  [1:0] idx;
    wire [3:0] an;

    // Expected output and error tracking (do not modify)
    reg  [3:0] expected_an;
    integer error_count;

    //------------------------------------------------------------------------
    // TODO #1: Module Instantiation
    //
    // Instantiate the anode_decode module as 'UUT'
    // Connect idx as input and an as output
    // (refer to halfadder_tb.v from Lab 4 for the pattern)
    //------------------------------------------------------------------------
    // YOUR CODE HERE:



    //------------------------------------------------------------------------
    // Test Stimulus
    //------------------------------------------------------------------------
    initial begin
        error_count = 0;

        $display("========================================");
        $display("Anode Decoder Testbench");
        $display("========================================");
        $display(" idx | an   | Expected | Status");
        $display("-----+------+----------+-------");

        //--------------------------------------------------------------------
        // TODO #2: Test All Four Index Values
        //
        // For each index value (0, 1, 2, 3):
        //   1. Set idx to the value
        //   2. Set expected_an to the correct pattern from the truth table
        //   3. Wait #10 for propagation
        //   4. Call check_output()
        //
        // Example for idx=0 (first one done for you):
        //--------------------------------------------------------------------
        idx = 2'd0; expected_an = 4'b1110; #10; check_output();
        // YOUR CODE HERE (add the remaining three test cases):



        //--------------------------------------------------------------------
        // Results (do not modify below this line)
        //--------------------------------------------------------------------
        $display("========================================");
        if (error_count == 0) begin
            $display("TEST PASSED - All outputs correct!");
        end else begin
            $display("TEST FAILED - %0d errors found", error_count);
        end
        $display("========================================");

        if (error_count == 0)
            $finish(0);
        else
            $finish(1);
    end

    //------------------------------------------------------------------------
    // Output Checking Task (do not modify)
    //------------------------------------------------------------------------
    task check_output;
        begin
            if (an !== expected_an) begin
                $display("  %0d  | %b | %b   | FAIL",
                         idx, an, expected_an);
                error_count = error_count + 1;
            end else begin
                $display("  %0d  | %b | %b   | ok",
                         idx, an, expected_an);
            end
        end
    endtask

endmodule
