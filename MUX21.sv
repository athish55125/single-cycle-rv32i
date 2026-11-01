`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2026 14:02:16
// Design Name: 
// Module Name: MUX21
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MUX21 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        sel,
    output logic [31:0] y
);

    assign y = sel ? b : a;

endmodule