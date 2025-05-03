`timescale 1ns / 1ps

(* dont_touch_hierarchy = "yes" *) module AES_128_en(
input [7:0] plaintext,
input mod, // mod0:encryption, mod1:decryption
input rst,
input start,
input clk,
input [7:0] ll_key, cheaper_key,
input [31:0] cheaper_key_ex,
input start_round,
output wire done,
output wire [7:0] cheapertext
    );
    
    reg [3:0] round;
    
    wire round_add, valid_out_2;
    
    wire [7:0] roundkey_out;
    
    wire valid_out_addrd1st;
    wire [7:0] data_out_addrd1st;
    
    wire valid_out_subbytes;
    wire [7:0] data_out_subbytes;
    
    wire valid_out_shiftrows;
    wire [7:0] data_out_shiftrows;
    
    wire valid_out_mixcolumn;
    wire [7:0] data_out_mixcolumn;
    
    wire valid_out_addroundkey;
    wire [7:0] data_out_addroundkey;
    
    wire [3:0]ll_key_sill = ll_key[3:0];
    
    wire valid_out_subbytes_last;
    wire [7:0] data_out_subbytes_last;
    
    wire valid_out_shiftrows_last;
    wire [7:0] data_out_shiftrows_last;
    
    
    //--------------------------------------------------------------

    addroundkey1st addroundkey1st(
        .data_in(plaintext),
        .round_key(cheaper_key),
        .clk(clk),
        .valid_in(start),
        .rst(rst),
        .valid_out(valid_out_addrd1st),
        .data_out(data_out_addrd1st)
        );
    
    //Encryption round-----------------------------------------------
    
    wire [7:0] data_in_subbytes;
    assign valid_in_subbytes = (valid_out_addrd1st)? valid_out_addrd1st : valid_out_2;
    assign data_in_subbytes = valid_out_addrd1st? data_out_addrd1st : data_out_addroundkey;
    
    assign valid_out_2 = (round < 4'b1001)? valid_out_addroundkey : 1'b0;
    
    always@(posedge clk)begin
        if(!rst)begin
            round <= 4'b0001;
        end
        else begin
        if(round_add)begin 
            round <= round + 1;
        end
        end
    end
    
    subbytes subbytes_rd(
       .clk(clk),
       .data_in(data_in_subbytes),
       .valid_in(valid_in_subbytes),
       .data_out(data_out_subbytes),
       .round(round),
       .rst(rst),
       .valid_out(valid_out_subbytes),
       .ll_key(ll_key)
       );
       
    shiftrows shiftrows_rd(
       .clk(clk),
       .data_in(data_out_subbytes),
       .valid_in(valid_out_subbytes),
       .data_out(data_out_shiftrows),
       .rst(rst),
       .valid_out(valid_out_shiftrows)
       );
     
    mixcolumn mixcolumn_rd(
       .clk(clk),
       .data_in(data_out_shiftrows),
       .valid_in(valid_out_shiftrows),
       .data_out(data_out_mixcolumn),
       .rst(rst),
       .valid_out(valid_out_mixcolumn),
       .mod(mod)
       );
       
    addroundkey addroundkey_rd(
        .data_in(data_out_mixcolumn),
        .round_key(roundkey_out),
        .clk(clk),
        .round(round),
        .valid_in(valid_out_mixcolumn),
        .rst(rst),
        .valid_out(valid_out_addroundkey),
        .round_o(round_add),
        .data_out(data_out_addroundkey)
        );
     
     assign valid_round = valid_out_mixcolumn | valid_out_shiftrows_last;
     
    (* DONT_TOUCH = "true" *) key_expansion key_expansion(
        .cheaper_key(cheaper_key_ex),
        .key_valid(start_round),
        .clk(clk),
        .valid_round(valid_round),
        .rst(rst),
        .round_out(roundkey_out),
        .ll_key(ll_key_sill)
        );   
        
    //Last round--------------------------------------------------------------
    
    assign valid_in_subbytes_last = (round > 4'b1000)? valid_out_addroundkey : 1'b0;
    
    subbytes subbytes_last(
       .clk(clk),
       .data_in(data_out_addroundkey),
       .valid_in(valid_in_subbytes_last),
       .data_out(data_out_subbytes_last),
       .round(round),
       .rst(rst),
       .valid_out(valid_out_subbytes_last),
       .ll_key(ll_key)
       );
       
   
   shiftrows shiftrows_last(
       .clk(clk),
       .data_in(data_out_subbytes_last),
       .valid_in(valid_out_subbytes_last),
       .data_out(data_out_shiftrows_last),
       .rst(rst),
       .valid_out(valid_out_shiftrows_last)
       );
        
   addroundkey addroundkey_last(
        .data_in(data_out_shiftrows_last),
        .round_key(roundkey_out),
        .clk(clk),
        .round(round),
        .valid_in(valid_out_shiftrows_last),
        .rst(rst),
        .valid_out(done),
        .data_out(cheapertext)
        );
    //--------------------------------------------------------------
    
endmodule
