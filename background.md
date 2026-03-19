# Background: Sequential Logic, TDM, and Parameterized Dividers

## Why TDM for 7-Segment Displays?

A Basys3 board has one 7-segment bus for segments and four anode enables for the four digits. Only one digit can be driven at a time. Time-Division Multiplexing (TDM) rapidly cycles which digit is active while updating the segment pattern for that digit, creating the appearance that all digits are lit simultaneously.

## Human Visual System and Refresh Rates

The display must refresh fast enough to appear steady (no visible flicker). A practical guideline is a few hundred Hz per digit or at least a few hundred Hz total scan rate per display. Faster scan rates generally look better, balanced against segment brightness and design constraints.

Key ideas:
- Flicker threshold: most people perceive steady light above ~60–100 Hz per element; we target ~200–400 Hz per digit to be conservative.
- Duty cycle: with 4 digits, each digit is active ~25% of the time; brightness depends on peak current and perceived integration over time.
- Balance: too slow → flicker; too fast → dimmer segments if current isn't increased (we keep current fixed on Basys3, so choose a sane scan rate).

## Sequential Building Blocks

1. CE Divider (Clock Enable Divider)
   - A parameterized down-counter that generates a one-cycle CE pulse every `VAL` clock cycles.
   - The counter counts down from `VAL-1` to `0`; when it reaches `0`, CE is asserted for one cycle and the counter reloads to `VAL-1`.
   - Using a parameter lets you choose a small `VAL` for simulation and a larger `VAL` for hardware without changing code.
   - Also supports `load` and `d` inputs for runtime reloading of the division value.

2. Scan Index
   - A 2-bit counter selects which digit is currently active (0..3).
   - Increments on each CE from the divider.

3. Anode Decode (Active-Low)
   - Maps the 2-bit index to one-hot active-low anode outputs, enabling one digit at a time.

4. Digit Mux
   - Picks the correct 4-bit nibble from the 16-bit switch input based on the current index.

5. 7-Segment Decoder
   - Converts a 4-bit hex value to active-low segment patterns.

## CE Divider Operation

The `ce_divide` module uses a down-counter pattern:

```
count:  VAL-1 → VAL-2 → ... → 1 → 0 → VAL-1 → VAL-2 → ...
CE:       0       0            0   1      0        0
```

- `ce = (count == 0)` — a single-cycle pulse every `VAL` clocks.
- On synchronous reset, the counter loads `VAL-1` (no spurious CE on reset release).
- The `load` input allows runtime override: when asserted, the counter loads `d-1`.

TDM timing math (with examples):
- Board clock: `f_clk = 100 MHz`.
- Divider: one CE pulse per `VAL` cycles → `f_tick = f_clk / VAL`.
- Per‑digit refresh: one out of four ticks per digit → `f_digit = f_tick / 4`.
- Example hardware picks:
  - `VAL = 250_000` → `f_tick = 400 Hz` → `f_digit = 100 Hz` (rock‑steady).
  - `VAL = 100_000` → `f_tick = 1000 Hz` → `f_digit = 250 Hz` (very smooth).
- Example simulation pick:
  - `VAL = 10` → `f_tick = 10 MHz` → fast enough to see multiple scan cycles quickly in sim.

## Reset and Enables

Use synchronous reset for counters to keep behavior well-defined at power-up and during simulation. Use CE to decouple the scan rate from the 100 MHz clock—logic still uses `clk`, but only updates on CE.

## Active-Low Conventions

- Segments (`seg[6:0]`) and anodes (`an[3:0]`) are active-low on Basys3.
- A `0` turns a segment or digit ON; a `1` turns it OFF.
- Anode mapping is typically:
  - idx=0 → rightmost digit → `an=4'b1110`
  - idx=1 → second digit   → `an=4'b1101`
  - idx=2 → third digit    → `an=4'b1011`
  - idx=3 → leftmost digit → `an=4'b0111`

## Putting It Together

The top-level ties these blocks together:
- `ce_divide` → derives CE
- `tdm_scan` → steps through digit indices
- `anode_decode` → drives active-low anodes
- `digit_mux` → selects the nibble from switches
- `hex_to_7seg` → produces the segment pattern for the active digit

Refer to the RTL diagrams included with the lab for signal flow and structural context.

Update sequencing and stability:
- On each CE, `tdm_scan` advances `idx`; combinational `anode_decode` and `digit_mux` react immediately, and `hex_to_7seg` updates `seg` in the same cycle.
- Because anodes and segments are active‑low, ensure mapping and nibble order match so digits don't "walk".
- Keep a safe `default` in combinational `case` statements (`an = 4'b1111`, `digit = 4'h0`) to avoid X‑propagation in sim.

Common pitfalls:
- Polarity mismatch (active‑low an/seg): verify with known patterns (e.g., hex `0` should turn on all segments except `g`).
- Index/nibble ordering mismatch: confirm rightmost digit is `sw[3:0]`, then `sw[7:4]`, `sw[11:8]`, `sw[15:12]`.
- Using a multi‑cycle CE: prefer a one‑cycle pulse to avoid uneven dwell per digit.

Further context (videos):
- TDM System Overview: https://www.youtube.com/watch?v=wy2LPfIW7TQ
- Human Perception and Frame Rates: https://www.youtube.com/watch?v=NSzje6I3BZA
