# Immediate Generator

Design the immediate generator. It builds the final 32-bit immediate from the decoder's `imm` / `imm_uj` fields.

### Module Specification

```SystemVerilog
module Imm_Gen(imm_input,imm_output,opcode,imm_input_uj,fn3);
input logic [11:0]imm_input;
input logic [2:0]fn3;
input logic [6:0]opcode;
output logic [31:0]imm_output;
input logic [19:0]imm_input_uj;

always_comb
begin
imm_output = 0;
case(opcode)
7'b1100011: //B-Type
imm_output = {{20{imm_input[11]}},imm_input}<<1;
7'b1101111: //JAL-Type
imm_output = {{12{imm_input_uj[19]}},imm_input_uj}<<1;
7'b0110111: //U-Type lui
imm_output = {{imm_input_uj},12'b0};
7'b1100111: //JALR-Type
imm_output = {{20{imm_input[11]}}, imm_input};
7'b0010111: //U-Type auipc
imm_output = {{imm_input_uj},12'b0};


 7'b0010011:
 begin // I-Type (immediate ALU ops)
      if (fn3 == 3'b001) 
      begin // SLLI
         imm_output = {27'b0, imm_input[4:0]};
      end
      else if (fn3 == 3'b101) 
      begin
         if (imm_input[11:5] == 7'b0000000) // SRLI
             imm_output = {27'b0, imm_input[4:0]};
      else if (imm_input[11:5] == 7'b0100000) // SRAI
               imm_output = {27'b0, imm_input[4:0]};
      end
      else
      begin // Other immediate ALU ops (e.g., ADDI, ANDI, ORI, etc.)
         imm_output = {{20{imm_input[11]}}, imm_input};
      end
 end

default:
begin
imm_output = {{20{imm_input[11]}},imm_input};
end
endcase
```

### Working

| Opcode | Result |
|---|---|
| Branch `1100011` | `sign_extend(imm_input) << 1` |
| JAL `1101111` | `sign_extend(imm_input_uj) << 1` (20-bit sign extension) |
| LUI `0110111`, AUIPC `0010111` | `{imm_input_uj, 12'b0}` |
| JALR `1100111` | `sign_extend(imm_input)` |
| I-type ALU `0010011` with `fn3 = 001` or `101` (shifts) | `{27'b0, imm_input[4:0]}` |
| I-type ALU `0010011`, other `fn3` | `sign_extend(imm_input)` |
| anything else (load, store, R-type, ...) | `sign_extend(imm_input)` |

### Interface

> [!IMPORTANT]
> Your module, port and parameter names are up to you. Your design must have the same number of ports, with the same directions and widths, as shown above, and must behave as specified. Map your names to this spec in `rnr-stage.yaml` (see the assignment handout).
