module register_file (
    input  logic [4:0]  rs1_sel, rs2_sel,
    input  logic        reg_write,
    input  logic        clk,
    input  logic        reset,              // async, active high
    input  logic [31:0] wb_data,
    input  logic [4:0]  rd_sel,
    output logic [31:0] rs1_data, rs2_data
);
    logic [31:0] register [0:31];
    integer i;

    // combinational reads, x0 hardwired to 0
    assign rs1_data = (rs1_sel == 5'd0) ? 32'b0 : register[rs1_sel];
    assign rs2_data = (rs2_sel == 5'd0) ? 32'b0 : register[rs2_sel];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                register[i] <= 32'b0;
        end else if (reg_write && rd_sel != 5'd0) begin
            register[rd_sel] <= wb_data;
        end
    end
endmodule
