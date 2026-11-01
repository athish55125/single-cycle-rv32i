# ID Stage (Instruction Decode)

Design the decode stage by connecting the **Decoder**, **Immediate Generator**, **Register File** and **Main Control**.

### Module Specification

```SystemVerilog
module ID_stage (
    input logic clk,
    input logic reset,

    input logic [31:0] instruction,

    // Writeback inputs from later pipeline stages
    input logic [4:0] wb_rd_sel,
    input logic [31:0] wb_data,
    input logic wb_reg_write,

    // Register file outputs
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    // Decoded fields
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    output logic [31:0] imm_output,

    // Control signals
    output logic branch,
    output logic mux_inp,
    output logic memread,
    output logic [1:0] memtoreg,
    output logic memwrite,
    output logic alusrc,
    output logic reg_write,
    output logic [2:0] aluop
);

    logic [6:0] opcode;
    logic [6:0] imm11_5;
    logic [2:0] fn3;
    logic [11:0] imm;
    logic [19:0] imm_ui;
    logic fn7_5;

    // 1. Instruction Decoder
    decoder D1 (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .imm11_5(imm11_5),
        .fn3(fn3),
        .imm(imm),
        .imm_ui(imm_ui),
        .fn7_5(fn7_5)
    );

    // 2. Register File
    register R1 (
        .clk(clk),
        .reset(reset),
        .rs1_sel(rs1),
        .rs2_sel(rs2),
        .rd_sel(wb_rd_sel),
        .wb_data(wb_data),
        .reg_write(wb_reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // 3. Immediate Generator
    Imm_Gen I1 (
        .imm_input(imm),
        .imm_output(imm_output),
        .opcode(opcode),
        .imm_input_uj(imm_ui),
        .fn3(fn3)
    );

    // 4. Control Unit
    control_unit C1 (
        .opcode(opcode),
        .branch(branch),
        .mux_inp(mux_inp),
        .memread(memread),
        .memtoreg(memtoreg),
        .memwrite(memwrite),
        .alusrc(alusrc),
        .reg_write(reg_write),
        .aluop(aluop)
    );

endmodule
```

### Working

- `instruction` goes through the **Decoder**; its `imm` / `imm_uj` / `fn3` / `opcode` feed the **Immediate Generator** (`imm_out`).
- The decoder's `rs1`, `rs2` select the Register File read ports; its `rd` is the write address.
- **Main Control** produces `branch`, `memtoreg`, `aluop`, `mem_write`, `alu_src`, `mem_read`, `mux_inp` and the register write enable.
- The register write enable is gated: **`reg_write && !stall`** (no register is written while stalled).
- `opcode_out_d`, `fn3_out_d`, `fn7_5`, `imm11_5` are the decoder's outputs, passed on.

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
