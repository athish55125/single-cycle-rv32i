# ALU Control

Design the ALU control decoder. It turns the operation class from Main Control, plus the instruction's `fn3` / `fn7_5` / `imm11_5` bits, into the ALU's 5-bit `alu_control` code.

### Module Specification

```SystemVerilog
module ALU_Ctrl (
    input  logic [2:0] aluop,
    input  logic [2:0] fn3,
    input  logic       fn7_5,
    output logic [3:0] alu_control
);

    always_comb begin
        case (aluop)

            3'b000: begin  // R-type
                case (fn3)
                    3'b000: alu_control = fn7_5 ? 4'b0001 : 4'b0000;
                    3'b001: alu_control = 4'b0101;
                    3'b010: alu_control = 4'b1000;
                    3'b011: alu_control = 4'b1001;
                    3'b100: alu_control = 4'b0100;
                    3'b101: alu_control = fn7_5 ? 4'b0111 : 4'b0110;
                    3'b110: alu_control = 4'b0011;
                    3'b111: alu_control = 4'b0010;
                    default: alu_control = 4'b0000;
                endcase
            end

            3'b001: begin  // I-type ALU operations
                case (fn3)
                    3'b000: alu_control = 4'b0000; // ADDI
                    3'b010: alu_control = 4'b1000; // SLTI
                    3'b011: alu_control = 4'b1001; // SLTIU
                    3'b100: alu_control = 4'b0100; // XORI
                    3'b110: alu_control = 4'b0011; // ORI
                    3'b111: alu_control = 4'b0010; // ANDI
                    3'b001: alu_control = 4'b0101; // SLLI
                    3'b101: alu_control = fn7_5 ? 4'b0111 : 4'b0110;
                    default: alu_control = 4'b0000;
                endcase
            end

            3'b010: alu_control = 4'b0000; // Load: address calculation
            3'b011: alu_control = 4'b0000; // Store: address calculation
            3'b100: alu_control = 4'b0001; // Branch: subtraction
            3'b101: alu_control = 4'b0000; // JAL/JALR address calculation
            3'b110: alu_control = 4'b1010; // LUI: pass B

            default: alu_control = 4'b0000;

        endcase
    end

endmodule
```

### Working

| alu_op | Class | control_out |
|---|---|---|
| `000` | R-type | by `fn3`: `000` ADD (SUB if `fn7_5`), `001` SLL, `010` SLT, `011` SLTU, `100` XOR, `101` SRL (SRA if `fn7_5`), `110` OR, `111` AND |
| `001` | I-type ALU | same `fn3` mapping, no SUB; `fn3 = 101` is SRAI if `imm11_5 == 7'h20`, else SRLI |
| `010` | Load | ADD |
| `011` | Store | ADD |
| `100` | Branch | by `fn3`: `000` BEQ, `001` BNE, `100` BLT, `101` BGE, `110` BLTU, `111` BGEU (other `fn3`: ADD) |
| `110` | JAL / LUI | ADD |
| other | - | ADD |

The output codes are the ALU's control table (`00000` ADD, `00001` SUB, `00010` XOR, `00011` OR, `00100` AND, `00101` SLL, `00110` SRL, `00111` SRA, `01000` SLT, `01001` SLTU, `01010`-`01111` BEQ BNE BLT BGE BLTU BGEU).

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
