`timescale 1ns / 1ps

module cubestripper(
input [7:0] data_in,
input [7:0] data_sbox,
output reg [7:0] data_out
    );
    
    always@(*)begin
        case(data_in)
            8'b10001010: data_out = ~data_sbox;
            8'b11101010: data_out = ~data_sbox;
            8'b11011010: data_out = ~data_sbox;
            8'b11000010: data_out = ~data_sbox;
            8'b11001110: data_out = ~data_sbox;
            8'b11001000: data_out = ~data_sbox;
            8'b11001011: data_out = ~data_sbox;
            8'b00101010: data_out = ~data_sbox;
            8'b00011010: data_out = ~data_sbox;
            8'b00000010: data_out = ~data_sbox;
            8'b00001110: data_out = ~data_sbox;
            8'b00001000: data_out = ~data_sbox;
            8'b00001011: data_out = ~data_sbox;
            8'b01111010: data_out = ~data_sbox;
            8'b01100010: data_out = ~data_sbox;
            8'b01101110: data_out = ~data_sbox;
            8'b01101000: data_out = ~data_sbox;
            8'b01101011: data_out = ~data_sbox;
            8'b01010010: data_out = ~data_sbox;
            8'b01011110: data_out = ~data_sbox;
            8'b01011000: data_out = ~data_sbox;
            8'b01011011: data_out = ~data_sbox;            
            8'b01000110: data_out = ~data_sbox;
            8'b01000000: data_out = ~data_sbox;
            8'b01000011: data_out = ~data_sbox;            
            8'b01001100: data_out = ~data_sbox;
            8'b01001101: data_out = ~data_sbox;
            8'b01001001: data_out = ~data_sbox;
            default: data_out = data_sbox;
        endcase    
    end
endmodule
