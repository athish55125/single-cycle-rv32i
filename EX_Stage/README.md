# EX Stage (Execute)

Design the execute stage: ALU operand selection, the ALU, and the branch / jump target and "taken" logic. It contains the **ALU** and the **ALU Control**.

### Module Specification

```SystemVerilog
module EX_Stage (
    input  logic [31:0] pc,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_output,
    input  logic [2:0]  aluop,
    input  logic [2:0]  fn3,
    input  logic        fn7_5,
    input  logic        branch,
    input  logic        alusrc,
    input  logic        mux_inp,

    output logic [31:0] alu_result,
    output logic        zero,
    output logic        and_out,
    output logic [31:0] pc_target
);

    logic [31:0] alu_b;
    logic [3:0]  alu_control;
    logic [31:0] pc_plus_imm;

    // 1. ALU control
    ALU_Ctrl ac (
        .aluop(aluop),
        .fn3(fn3),
        .fn7_5(fn7_5),
        .alu_control(alu_control)
    );

    // 2. Select second ALU operand
    MUX21 mux_ex (
        .a(rs2_data),
        .b(imm_output),
        .sel(alusrc),
        .y(alu_b)
    );

    // 3. ALU
    ALU alu1 (
        .A(rs1_data),
        .B(alu_b),
        .ALU_Control(alu_control),
        .Result(alu_result),
        .Zero(zero)
    );

    // 4. Branch decision
    AND_Gate and_ex (
        .branch(branch),
        .zero(zero),
        .and_out(and_out)
    );

    // 5. Calculate PC + immediate
    IF_Adder ex_add (
        .pc(pc),
        .imm(imm_output),
        .pc_target(pc_plus_imm)
    );

    // 6. Select next PC target
    MUX21 mux_pc (
        .a(pc + 32'd4),
        .b(pc_plus_imm),
        .sel(and_out | mux_inp),
        .y(pc_target)
    );

endmodule
```

### Working

- ALU operand B is `imm_out` when `alu_src` is 1, else `rs2_data`; operand A is `rs1_data`.
- The ALU control comes from **ALU Control** (`aluop`, `fn3`, `imm11_5`, `fn7_5`); the ALU's `zero` output is the branch condition.
- `pc_signed_offset = address + imm_out`.
- `pc_ex_out` = `{alu_out[31:1], 1'b0}` when `mux_inp` is 1 (JALR), otherwise `pc_signed_offset`.
- `and_out_ex = (branch && zero) || opcode == 7'h6F (JAL) || opcode == 7'h67 (JALR)`.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
