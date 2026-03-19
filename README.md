# Lab 7: Hex Display with Time-Division Multiplexing (TDM)

## Overview

In this lab, you will build a time-division multiplexed (TDM) 4-digit hex display for the Basys3 board. The Basys3 has four 7-segment digits that share a single segment bus -- only one digit can be driven at a time. By cycling through the digits fast enough (hundreds of Hz), all four appear to be lit simultaneously.

You will integrate five modules into a working display system:
1. **CE Divider** (clock enable divider) -- divides the 100 MHz clock and generates a one-cycle clock-enable (CE) pulse every `DIV_VAL` clocks
2. **TDM Scan** -- 2-bit counter that selects which digit is active (0..3)
3. **Anode Decoder** -- maps the scan index to active-low one-hot anode outputs
4. **Digit Mux** -- selects the correct 4-bit nibble from the 16 switches
5. **Hex-to-7seg Decoder** -- converts each nibble to active-low segment patterns

The CE divider, scan controller, and hex-to-7seg decoder are provided complete. You will implement the anode decoder, finish the digit mux, wire the top-level module, and write a testbench.

**Design Hierarchy:**
```
hex_tdm_top (top-level wrapper)
├── ce_divide    - Clock enable divider (CE every DIV_VAL clocks)
├── tdm_scan     - 2-bit rotating digit index
├── anode_decode - Active-low anode selection (YOU IMPLEMENT)
├── digit_mux    - Nibble selector from switches (YOU COMPLETE)
└── hex_to_7seg  - Hex-to-segment decoder
```

**RTL Diagram:**

![RTL Diagram for hex_tdm_top](../Assets/rtl_hex_tdm_top.jpg)

---

## Pre-Lab / Background

1. Review sequential logic basics (D flip-flops, synchronous reset, enable)
2. Review Verilog parameters and how to override them at instantiation
3. Recall active-low conventions for 7-segment displays and anodes
4. Read the background notes in `background.md` for clock division and TDM theory

---

## Your Tasks

1. **Implement `rtl/anode_decode.v`** -- Write the combinational case statement mapping idx to active-low anode patterns
2. **Complete `rtl/digit_mux.v`** -- Add the two missing case entries for idx=2 and idx=3
3. **Complete `rtl/hex_tdm_top.v`** -- Declare wires (TODO #1) and instantiate all five submodules (TODOs #2-#6)
4. **Complete `tb/anode_decode_tb.v`** -- Instantiate the DUT and add the three remaining test vectors

---

## Lab Activities

### Step 1: Vivado Project Setup
- [ ] Download the Lab 7 template files
- [ ] Launch Vivado and create a new project
- [ ] Set the project location *outside* of the template directory
- [ ] Add all `.v` files from `rtl/` as **design sources**
- [ ] Add testbench files from `tb/` as **simulation sources**
- [ ] Add the constraint file from `constraints/`
- [ ] Select the Basys3 board as target

### Step 2: Anode Decoder
- [ ] Open `rtl/anode_decode.v` and implement the case statement
- [ ] Hint: Model it after `rtl/hex_to_7seg.v` -- same pattern, different mapping
- [ ] Open `tb/anode_decode_tb.v` and complete the TODOs (instantiate DUT, add test vectors)
- [ ] Set `anode_decode_tb` as the simulation top module and run simulation
- [ ] Verify all 4 index values produce correct anode patterns

### Step 3: Digit Mux
- [ ] Open `rtl/digit_mux.v` and add the two missing cases
- [ ] This is straightforward -- follow the pattern of the two provided cases

### Step 4: Top-Level Integration
- [ ] Open `rtl/hex_tdm_top.v` and work through TODOs #1-#6
- [ ] Use the RTL diagram (`../Assets/rtl_hex_tdm_top.jpg`) as your guide
- [ ] TODO #1: Declare the internal wires
- [ ] TODOs #2-#6: Instantiate each submodule with correct port connections

### Step 5: Simulation
- [ ] Set `hex_tdm_top_tb` as the simulation top module
- [ ] Run behavioral simulation and observe `an` cycling through one-hot patterns
- [ ] Verify `seg` outputs match expected patterns for each digit
- [ ] Try different `sw` values (e.g., `16'h1234`, `16'hABCD`)
- [ ] Use a small `DIV_VAL` parameter (e.g., 10) for simulation to see scanning quickly

### Step 6: Hardware Implementation
- [ ] Set `hex_tdm_top` as the top module for synthesis (default `DIV_VAL=250_000` gives ~400 Hz CE)
- [ ] Synthesize, implement, and generate bitstream
- [ ] Program the Basys3 and verify a stable, flicker-free 4-digit display

---

## Checking Your Work

When you push your code, GitHub Actions will automatically compile and test your modules:

| CI Job | What It Tests | Files Compiled |
|--------|--------------|----------------|
| `test-ce-divide` | CE divider with clock enable | `ce_divide.v` + `ce_divide_tb.v` |
| `test-hex-tdm-top` | Full TDM display system | All 6 RTL files + `hex_tdm_top_tb.v` |

Both jobs must show **TEST PASSED** for full credit.

> **Note:** `anode_decode` is validated indirectly through the integration test (`test-hex-tdm-top`). If the integration test passes, your anode decoder and digit mux are working correctly.

---

## File Structure

```
├── rtl/
│   ├── ce_divide.v          # Clock enable divider (provided)
│   ├── tdm_scan.v           # 2-bit scan controller (provided)
│   ├── anode_decode.v       # Active-low anode decoder (you implement)
│   ├── digit_mux.v          # Nibble mux (you complete)
│   ├── hex_tdm_top.v        # Top-level integration (you complete)
│   └── hex_to_7seg.v        # Hex-to-segment decoder (provided)
├── tb/
│   ├── ce_divide_tb.v       # CE divider testbench (provided, CI-tested)
│   ├── anode_decode_tb.v    # Anode decoder testbench (you complete)
│   └── hex_tdm_top_tb.v     # Integration testbench (provided, CI-tested)
├── constraints/
│   └── basys3.xdc           # Pin assignments for Basys3
└── .github/workflows/
    └── test.yml              # CI - auto-tests on push
```

---

## Hardware Interface

### Inputs
| Port | Pins | Description |
|------|------|-------------|
| `clk` | W5 | 100 MHz system clock |
| `btnC` | U18 | Center button = synchronous reset (active-high) |
| `sw[15:0]` | V17..R2 | 16 slide switches = four hex digits |

### Outputs
| Port | Pins | Description |
|------|------|-------------|
| `seg[6:0]` | W7..U7 | 7-segment cathodes {g,f,e,d,c,b,a} (active-low) |
| `an[3:0]` | U2..W4 | 7-segment anodes (active-low, one-hot) |

### Switch-to-Digit Mapping
| Switches | Digit Position | Anode |
|----------|---------------|-------|
| `sw[3:0]` | Rightmost (digit 0) | `an[0]` |
| `sw[7:4]` | Second from right (digit 1) | `an[1]` |
| `sw[11:8]` | Third from right (digit 2) | `an[2]` |
| `sw[15:12]` | Leftmost (digit 3) | `an[3]` |

---

## What to Submit

Demo your working hardware to the instructor during lab. Set different switch patterns and show a stable, flicker-free 4-digit hex display on the Basys3.

No code submission is required -- GitHub CI will verify your Verilog automatically when you push.

---

## Common Issues and Troubleshooting

### Synthesis Errors
- **Missing wires in `hex_tdm_top.v`**: Make sure you declared all internal wires (TODO #1)
- **Port mismatch**: Verify port names match exactly between your instantiations and the module definitions
- **Undeclared module**: Ensure all six `.v` files from `rtl/` are added to the Vivado project

### Simulation Issues
- **Blank display (all segments off)**: Check that `anode_decode` outputs active-low (0 = ON)
- **Wrong digit on wrong position**: Verify nibble order in `digit_mux` matches anode order in `anode_decode`
- **No scanning (stuck on one digit)**: Check that `ce` is connected to `tdm_scan` in the top-level

### Hardware Issues
- **Flickering display**: Use a larger `DIV_VAL` parameter (increase to slow the scan rate)
- **Digits appear but in wrong order**: Check switch-to-nibble and index-to-anode mapping
- **All segments on/off**: Verify active-low polarity in constraint file matches your design
