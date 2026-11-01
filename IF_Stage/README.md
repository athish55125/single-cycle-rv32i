# IF Stage (Instruction Fetch)

Design the instruction-fetch stage: the program counter register and the next-PC selection.

### Module Specification

```SystemVerilog
module IF (
    input  logic clk,
    input  logic reset,
    input  logic stall,
    input  logic and_out,
    output logic[31:0] pc_next,
    input  logic[31:0] pc_signed_offset,
    output logic[31:0] address,
    output logic[31:0] pc_new
);

assign pc_new= address+32'd4;
always_comb begin
    if (and_out)
    pc_next = pc_signed_offset;
    else
    pc_next = pc_new;
    end
always_ff @(posedge clk or posedge reset) begin
if (reset)
address <= 32'h0000_0000;
else if (!stall)
address <= pc_next;
end
endmodule
```

### Working

- `pc_new = address + 4`.
- Next PC is `pc_signed_offset` when `and_out` is high, otherwise `pc_new`.
- On the rising edge of `clk` the PC register loads the next PC, **unless `stall` is high**, in which case it holds.
- On `reset` (asynchronous, active high) the PC becomes **`32'h8000_0000`**.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
