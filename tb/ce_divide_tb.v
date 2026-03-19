//============================================================================
// Testbench: Clock Enable Divider (ce_divide)
//
// Self-checking testbench that verifies:
//   1. Reset loads counter to VAL-1 and CE is low
//   2. CE fires after VAL clocks (count reaches 0)
//   3. CE is a single-cycle pulse
//   4. Load overrides normal counting
//   5. Multiple CE periods are consistent
//   6. Reset during counting
//
// Uses VAL=10 for fast simulation.
//============================================================================

`timescale 1ns/1ps

module ce_divide_tb;

    //------------------------------------------------------------------------
    // Parameters
    //------------------------------------------------------------------------
    localparam VAL    = 10;             // Small value for fast sim
    localparam W      = $clog2(VAL);    // Counter width
    localparam PERIOD = 10;             // 100 MHz clock

    //------------------------------------------------------------------------
    // Signal Declarations
    //------------------------------------------------------------------------
    reg              clk;
    reg              rst;
    reg              load;
    reg  [W-1:0]     d;
    wire             ce;

    // Error tracking
    integer error_count;
    integer test_num;

    //------------------------------------------------------------------------
    // Unit Under Test (UUT)
    //------------------------------------------------------------------------
    ce_divide #(.VAL(VAL)) UUT (
        .clk(clk),
        .rst(rst),
        .load(load),
        .d(d),
        .ce(ce)
    );

    //------------------------------------------------------------------------
    // Clock Generation
    //------------------------------------------------------------------------
    initial clk = 0;
    always #(PERIOD/2) clk = ~clk;

    //------------------------------------------------------------------------
    // Test Stimulus
    //------------------------------------------------------------------------
    initial begin
        error_count = 0;
        test_num = 0;

        $display("================================================");
        $display("CE Divider Testbench (VAL=%0d)", VAL);
        $display("================================================");

        //--------------------------------------------------------------------
        // Test 1: Reset loads counter to VAL-1, CE is low
        //--------------------------------------------------------------------
        rst  = 1;
        load = 0;
        d    = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;
        test_num = test_num + 1;
        if (ce !== 1'b0) begin
            $display("Test %0d FAIL: CE high during reset (ce=%b, expected 0)", test_num, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: CE low during reset", test_num);
        end

        //--------------------------------------------------------------------
        // Test 2: CE fires after VAL clocks from reset release
        // After reset, count = VAL-1 = 9. Needs VAL-1 clocks to reach 0.
        //--------------------------------------------------------------------
        rst = 0;
        repeat(VAL - 1) @(posedge clk);
        #1;
        test_num = test_num + 1;
        if (ce !== 1'b1) begin
            $display("Test %0d FAIL: CE not asserted after %0d clocks (ce=%b)", test_num, VAL, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: CE asserted after %0d clocks", test_num, VAL);
        end

        //--------------------------------------------------------------------
        // Test 3: CE is a one-cycle pulse
        //--------------------------------------------------------------------
        @(posedge clk); #1;
        test_num = test_num + 1;
        if (ce !== 1'b0) begin
            $display("Test %0d FAIL: CE still high after pulse (ce=%b)", test_num, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: CE is one-cycle pulse (cleared next cycle)", test_num);
        end

        //--------------------------------------------------------------------
        // Test 4: Second CE pulse after another VAL clocks
        //--------------------------------------------------------------------
        repeat(VAL - 1) @(posedge clk);
        #1;
        test_num = test_num + 1;
        if (ce !== 1'b1) begin
            $display("Test %0d FAIL: Second CE pulse not detected (ce=%b)", test_num, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: Second CE pulse after %0d clocks", test_num, VAL);
        end

        //--------------------------------------------------------------------
        // Test 5: Third CE pulse (verify consistent period)
        //--------------------------------------------------------------------
        repeat(VAL) @(posedge clk);
        #1;
        test_num = test_num + 1;
        if (ce !== 1'b1) begin
            $display("Test %0d FAIL: Third CE pulse not detected (ce=%b)", test_num, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: Third CE pulse - period is consistent", test_num);
        end

        //--------------------------------------------------------------------
        // Test 6: Load during counting overrides counter
        //--------------------------------------------------------------------
        @(posedge clk); #1;  // Move past CE
        repeat(3) @(posedge clk);  // Count down a few cycles
        load = 1;
        d    = 3;  // Load with d=3 so count starts at 2
        @(posedge clk); #1;
        load = 0;
        test_num = test_num + 1;
        if (ce !== 1'b0) begin
            $display("Test %0d FAIL: CE high immediately after load (ce=%b)", test_num, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: Load overrides counting, CE low", test_num);
        end

        // count is now 2 (d-1=3-1=2), CE should fire after 2 more clocks
        repeat(2) @(posedge clk);
        #1;
        test_num = test_num + 1;
        if (ce !== 1'b1) begin
            $display("Test %0d FAIL: CE not asserted after load countdown (ce=%b)", test_num, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: CE fires after loaded countdown", test_num);
        end

        //--------------------------------------------------------------------
        // Test 7: Reset during counting clears counter
        //--------------------------------------------------------------------
        @(posedge clk); #1;  // Move past CE
        repeat(3) @(posedge clk);  // Count down a few cycles
        rst = 1;
        @(posedge clk); #1;
        test_num = test_num + 1;
        if (ce !== 1'b0) begin
            $display("Test %0d FAIL: CE high during mid-count reset (ce=%b)", test_num, ce);
            error_count = error_count + 1;
        end else begin
            $display("Test %0d ok: Mid-count reset clears CE", test_num);
        end
        rst = 0;

        //--------------------------------------------------------------------
        // Results
        //--------------------------------------------------------------------
        $display("================================================");
        if (error_count == 0) begin
            $display("TEST PASSED - All %0d tests correct!", test_num);
        end else begin
            $display("TEST FAILED - %0d errors out of %0d tests", error_count, test_num);
        end
        $display("================================================");

        if (error_count == 0)
            $finish(0);
        else
            $finish(1);
    end

endmodule
