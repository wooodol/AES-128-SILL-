`timescale 1ns / 1ps

module AES_128_de(
input [7:0] cheapertext,
input mod, // mod0:encryption, mod1:decryption
input rst,
input start,
input clk,
input [7:0] ll_key, cheaper_key,
input [31:0] cheaper_key_ex,
input start_round,
output wire done, key_gen_complete,
output wire [7:0] plaintext
    );
    
    reg [3:0] round;
    wire round_add;
    
    //key expantion
    wire [7:0] roundkey_out;
    wire [3:0]ll_key_sill = ll_key[3:0];
    
    //decryption round
    wire valid_out_addrd1st;
    wire [7:0] data_out_addrd1st;
    
    wire [7:0] data_out_invshiftrows;
    wire valid_out_invshiftrows;
    
    wire [7:0] data_out_invsubbytes;
    wire valid_out_invsubbytes;    
    
    wire [7:0] data_out_invaddroundkey;
    wire valid_out_invaddroundkey;
    
    wire [7:0] data_out_invmixcolumns;
    wire valid_out_invmixcolumns;
    
    wire [7:0] data_out_invshiftrows_last;
    wire valid_out_invshiftrows_last;
    
    wire [7:0] data_out_invsubbytes_last;
    wire valid_out_invsubbytes_last;
    
    // key expansion----------------------------------------------------------------------
    assign valid_round = start | valid_out_invsubbytes | valid_out_invsubbytes_last;
    
    (* DONT_TOUCH = "true" *) key_expansion_de key_expansion_de(
        .cheaper_key(cheaper_key_ex),
        .key_valid(start_round),
        .clk(clk),
        .valid_round(valid_round),
        .rst(rst),
        .round_out(roundkey_out),
        .ll_key(ll_key_sill),
        .key_gen_complete(key_gen_complete)
        ); 
        
    // 1st-----------------------------------------------------------
   invaddroundkey1st invaddroundkey1st(
        .data_in(cheapertext),
        .round_key(roundkey_out),
        .clk(clk),
        .valid_in(start),
        .rst(rst),
        .valid_out(valid_out_addrd1st),
        .data_out(data_out_addrd1st)
        ); 
            
    // decryption round--------------------------------------------
    
    wire [7:0] data_in_invshiftrows;
    assign valid_in_invshiftrows = (valid_out_addrd1st)? valid_out_addrd1st : valid_out_2;
    assign data_in_invshiftrows = valid_out_addrd1st? data_out_addrd1st : data_out_invmixcolumns;
    
    assign valid_out_2 = (round < 4'b1001)? valid_out_invmixcolumns : 1'b0;
    
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
    
    invshiftrows invshiftrows_rd(
       .clk(clk),
       .data_in(data_in_invshiftrows),
       .valid_in(valid_in_invshiftrows),
       .data_out(data_out_invshiftrows),
       .rst(rst),
       .valid_out(valid_out_invshiftrows)
       );     
       
       
    invsubbytes invsubbytes_rd(
       .clk(clk),
       .data_in(data_out_invshiftrows),
       .valid_in(valid_out_invshiftrows),
       .data_out(data_out_invsubbytes),
       .round(round),
       .rst(rst),
       .valid_out(valid_out_invsubbytes),
       .ll_key(ll_key)
       );
       
   
    invaddroundkey invaddroundkey_rd(
        .data_in(data_out_invsubbytes),
        .round_key(roundkey_out),
        .clk(clk),
        .valid_in(valid_out_invsubbytes),
        .rst(rst),
        .valid_out(valid_out_invaddroundkey),
        .data_out(data_out_invaddroundkey)
        );    
       
       
    invmixcolumn invmixcolumn_rd(
       .clk(clk),
       .data_in(data_out_invaddroundkey),
       .valid_in(valid_out_invaddroundkey),
       .data_out(data_out_invmixcolumns),
       .rst(rst),
       .valid_out(valid_out_invmixcolumns),
       .round_o(round_add),
       .mod(mod)
       );
       
    //---------------------------------------------------------------     
    assign valid_in_invshiftrows_last = (round > 4'b1000)? valid_out_invmixcolumns : 1'b0;
    
    invshiftrows invshiftrows_last(
       .clk(clk),
       .data_in(data_out_invmixcolumns),
       .valid_in(valid_in_invshiftrows_last),
       .data_out(data_out_invshiftrows_last),
       .rst(rst),
       .valid_out(valid_out_invshiftrows_last)
       );     
       
       
    invsubbytes invsubbytes_last(
       .clk(clk),
       .data_in(data_out_invshiftrows_last),
       .valid_in(valid_out_invshiftrows_last),
       .data_out(data_out_invsubbytes_last),
       .round(round),
       .rst(rst),
       .valid_out(valid_out_invsubbytes_last),
       .ll_key(ll_key)
       );
       
   
    invaddroundkey invaddroundkey_last(
        .data_in(data_out_invsubbytes_last),
        .round_key(roundkey_out),
        .clk(clk),
        .valid_in(valid_out_invsubbytes_last),
        .rst(rst),
        .valid_out(done),
        .data_out(plaintext)
        );    
        
endmodule
