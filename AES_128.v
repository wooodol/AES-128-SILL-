`timescale 1ns / 1ps

module AES_128(
input [127:0] data_in,
input mod, // mod0:encryption, mod1:decryption
input rst,
input start,
input clk,
input [7:0] key,
input [7:0] round_key,
input start_round,
output wire valid_out,
output wire [7:0] data_out
    );
    
    wire [7:0] round_out;
    
    wire valid_out_subbytes;
    wire [7:0] data_out_subbytes;
    
    wire valid_out_shiftrows;
    wire [7:0] data_out_shiftrows;
    
    wire valid_out_mixcolumn;
    wire [7:0] data_out_mixcolumn;
    
    subbytes subbytes(
       .clk(clk),
       .data_in(data_in),
       .valid_in(start),
       .data_out(data_out_subbytes),
       .rst(rst),
       .valid_out(valid_out_subbytes),
       .key(key)
       );
       
    shiftrows shiftrows(
       .clk(clk),
       .data_in(data_out_subbytes),
       .valid_in(valid_out_subbytes),
       .data_out(data_out_shiftrows),
       .rst(rst),
       .valid_out(valid_out_shiftrows)
       );
     
    mixcolumn mixcolumn(
       .clk(clk),
       .data_in(data_out_shiftrows),
       .valid_in(valid_out_shiftrows),
       .data_out(data_out_mixcolumn),
       .rst(rst),
       .valid_out(valid_out_mixcolumn),
       .mod(mod)
       );
       
    addroundkey addroundkey(
        .data_in(data_out_mixcolumn),
        .round_key(round_out),
        .clk(clk),
        .valid_in(valid_out_mixcolumn),
        .rst(rst),
        .valid_out(valid_out),
        .data_out(data_out)
        );
     
    key_expansion key_expansion(
        .round_key(round_key),
        .key_valid(start_round),
        .clk(clk),
        .valid_round(valid_out_mixcolumn),
        .rst(rst),
        .round_out(round_out)
        );   
    
endmodule
