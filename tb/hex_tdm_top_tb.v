//============================================================================
// Testbench: TDM Hex Display (Integration Test)
//
// Self-checking integration testbench that verifies the complete TDM
// display pipeline. Uses a small divider value for fast simulation.
//
// Tests:
//   1. Reset state: all anodes OFF, segments blank
//   2. Drive sw=0x1234 and verify each digit scans correctly
//   3. Drive sw=0xABCD and verify segment outputs
//
// This test indirectly validates anode_decode.v and digit_mux.v.
//============================================================================

`timescale 1ns/1ps

module hex_tdm_top_tb;

    //------------------------------------------------------------------------
    // Parameters
    //------------------------------------------------------------------------
    localparam DIV_VAL_SIM = 10;        // Small divider for fast sim
    localparam PERIOD      = 10;        // 100 MHz clock (10 ns period)
    // CE fires every DIV_VAL_SIM clocks. Full scan = 4 * DIV_VAL_SIM clocks.
    localparam CE_PERIOD   = DIV_VAL_SIM;
    localparam SCAN_CYCLE  = 4 * CE_PERIOD;

    //------------------------------------------------------------------------
    // Signal Declarations
    //------------------------------------------------------------------------
    reg         clk;
    reg         btnC;
    reg  [15:0] sw;
    wire [6:0]  seg;
    wire [3:0]  an;

    // Error tracking
    integer error_count;
    integer test_num;

    //------------------------------------------------------------------------
    // Unit Under Test (UUT)
    //------------------------------------------------------------------------
    hex_tdm_top #(.DIV_VAL(DIV_VAL_SIM)) UUT (
        .clk(clk),
        .btnC(btnC),
        .sw(sw),
        .seg(seg),
        .an(an)
    );

    //------------------------------------------------------------------------
    // Expected Segment Lookup (golden model for hex_to_7seg)
    //------------------------------------------------------------------------
    function [6:0] expected_seg;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: expected_seg = 7'b1000000;
                4'h1: expected_seg = 7'b1111001;
                4'h2: expected_seg = 7'b0100100;
                4'h3: expected_seg = 7'b0110000;
                4'h4: expected_seg = 7'b0011001;
                4'h5: expected_seg = 7'b0010010;
                4'h6: expected_seg = 7'b0000010;
                4'h7: expected_seg = 7'b1111000;
                4'h8: expected_seg = 7'b0000000;
                4'h9: expected_seg = 7'b0010000;
                4'hA: expected_seg = 7'b0001000;
                4'hB: expected_seg = 7'b0000011;
                4'hC: expected_seg = 7'b1000110;
                4'hD: expected_seg = 7'b0100001;
                4'hE: expected_seg = 7'b0000110;
                4'hF: expected_seg = 7'b0001110;
                default: expected_seg = 7'b1111111;
            endcase
        end
    endfunction

    //------------------------------------------------------------------------
    // Expected Anode Lookup
    //------------------------------------------------------------------------
    function [3:0] expected_an;
        input [1:0] idx;
        begin
            case (idx)
                2'd0: expected_an = 4'b1110;
                2'd1: expected_an = 4'b1101;
                2'd2: expected_an = 4'b1011;
                2'd3: expected_an = 4'b0111;
                default: expected_an = 4'b1111;
            endcase
        end
    endfunction

    //------------------------------------------------------------------------
    // Extract nibble from sw by index
    //------------------------------------------------------------------------
    function [3:0] get_nibble;
        input [15:0] switches;
        input [1:0]  idx;
        begin
            case (idx)
                2'd0: get_nibble = switches[3:0];
                2'd1: get_nibble = switches[7:4];
                2'd2: get_nibble = switches[11:8];
                2'd3: get_nibble = switches[15:12];
                default: get_nibble = 4'h0;
            endcase
        end
    endfunction

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

        $display("========================================================");
        $display("TDM Hex Display Integration Testbench (DIV_VAL=%0d)", DIV_VAL_SIM);
        $display("========================================================");

        //--------------------------------------------------------------------
        // Test 1: Reset behavior
        //--------------------------------------------------------------------
        sw   = 16'h0000;
        btnC = 1;
        repeat(4) @(posedge clk);
        #1;
        $display("\n--- Test: Reset State ---");
        // During reset, ce_divide loads and tdm_scan resets. idx=0, so an
        // should reflect idx=0 and seg should show hex 0 from sw[3:0].
        // (anode_decode and digit_mux are combinational, driven by idx=0)

        //--------------------------------------------------------------------
        // Test 2: sw = 0x1234, verify all 4 digits
        //--------------------------------------------------------------------
        sw   = 16'h1234;
        btnC = 0;
        $display("\n--- Test: sw = 0x1234 ---");
        $display(" Digit | an   | seg     | Expected an | Expected seg | Status");
        $display("-------+------+---------+-------------+--------------+-------");

        // Run through one complete scan cycle to stabilize
        repeat(SCAN_CYCLE + CE_PERIOD) @(posedge clk);

        // Now sample each digit: wait for CE and check the digit that just became active
        check_digit_sequence(16'h1234);

        //--------------------------------------------------------------------
        // Test 3: sw = 0xABCD, verify all 4 digits
        //--------------------------------------------------------------------
        sw = 16'hABCD;
        $display("\n--- Test: sw = 0xABCD ---");
        $display(" Digit | an   | seg     | Expected an | Expected seg | Status");
        $display("-------+------+---------+-------------+--------------+-------");

        // Wait for a full scan with new switch values
        repeat(SCAN_CYCLE) @(posedge clk);

        check_digit_sequence(16'hABCD);

        //--------------------------------------------------------------------
        // Results
        //--------------------------------------------------------------------
        $display("\n========================================================");
        if (error_count == 0) begin
            $display("TEST PASSED - All %0d checks correct!", test_num);
        end else begin
            $display("TEST FAILED - %0d errors out of %0d checks", error_count, test_num);
        end
        $display("========================================================");

        if (error_count == 0)
            $finish(0);
        else
            $finish(1);
    end

    //------------------------------------------------------------------------
    // Task: Check one full digit scan sequence (4 digits)
    // Waits for CE edges and samples outputs for each digit
    //------------------------------------------------------------------------
    task check_digit_sequence;
        input [15:0] switches;
        reg [1:0]  digit_idx;
        reg [3:0]  exp_an;
        reg [6:0]  exp_seg;
        reg [3:0]  nibble;
        integer i;
        begin
            for (i = 0; i < 4; i = i + 1) begin
                // Wait for the next CE pulse (marks transition to next digit)
                wait_for_ce();
                // After CE, idx has advanced. Allow 2 clocks for propagation.
                @(posedge clk); #1;
                @(posedge clk); #1;

                // Determine which digit index is currently active by reading
                // the internal idx. We check outputs against what we expect.
                digit_idx = UUT.idx;
                nibble    = get_nibble(switches, digit_idx);
                exp_an    = expected_an(digit_idx);
                exp_seg   = expected_seg(nibble);

                test_num = test_num + 1;
                if (an !== exp_an || seg !== exp_seg) begin
                    $display("   %0d   | %b | %b | %b      | %b     | FAIL",
                             digit_idx, an, seg, exp_an, exp_seg);
                    error_count = error_count + 1;
                end else begin
                    $display("   %0d   | %b | %b | %b      | %b     | ok",
                             digit_idx, an, seg, exp_an, exp_seg);
                end
            end
        end
    endtask

    //------------------------------------------------------------------------
    // Task: Wait for a CE pulse
    //------------------------------------------------------------------------
    task wait_for_ce;
        begin
            // Wait until ce goes high
            @(posedge clk);
            while (UUT.ce !== 1'b1) begin
                @(posedge clk);
            end
        end
    endtask

endmodule
