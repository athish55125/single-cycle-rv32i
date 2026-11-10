module imm_generator (
    input  logic [11:0] imm_input,
    input  logic [2:0]  fn3,
    input  logic [6:0]  opcode,
    input  logic [19:0] imm_input_uj,
    output logic [31:0] imm_output
);
    logic [31:0] sext12;
    logic [31:0] sext20;

    assign sext12 = {{20{imm_input[11]}},    imm_input};
    assign sext20 = {{12{imm_input_uj[19]}}, imm_input_uj};

    always_comb begin
        case (opcode)
            7'b1100011: imm_output = sext12 << 1;                  // Branch
            7'b1101111: imm_output = sext20 << 1;                  // JAL
            7'b0110111,
            7'b0010111: imm_output = {imm_input_uj, 12'b0};        // LUI / AUIPC
            7'b1100111: imm_output = sext12;                       // JALR
            7'b0010011: begin                                      // I-type ALU
                if (fn3 == 3'b001 || fn3 == 3'b101)
                    imm_output = {27'b0, imm_input[4:0]};          // shifts
                else
                    imm_output = sext12;
            end
            default:    imm_output = sext12;                       // load, store, R, ...
        endcase
    end
endmodule
