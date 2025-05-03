`timescale 1ns / 1ps

module subbytes(
input [7:0] data_in,
input clk,
input valid_in,
input [3:0] round,
input rst,
input [7:0] ll_key,
output reg [7:0] data_out,
output reg valid_out
    );
    
    reg[4:0] count;
    reg[7:0] data_in_buf, data_in_delayed; //flattening data_in
    wire [7:0] data_in_sbox, data_out_sbox, data_out_SFLL;
    assign data_in_sbox[7:0] = data_in_buf;
                                
    always@(posedge clk or negedge rst)begin
        if(!rst)begin  //reset
            count <= 5'b00000;
            valid_out <= 1'b0;
            data_out <= 8'b0;
            data_in_buf <= 8'b0;
        end
        else if(valid_in && (round < 4'b1010))begin      
            data_in_buf[7:0] <= data_in;    
            if(count<5'b10010)begin
                if(count>5'b00001)begin
                    /*
                    data_out[7:0] <= data_out_SFLL[7:0];
                    */
                    data_out[7:0] <= data_out_sbox[7:0];
                    valid_out <= 1'b1;
                end
                count <= count + 1'b00001;  
            end
            else if(count == 5'b10010) begin
                count <= 5'b00000;
                valid_out <= 1'b0;
            end 
        end   
        else if(count == 5'b10000) begin
            data_out[7:0] <= data_out_sbox[7:0];
            valid_out <= 1'b1;
            count <= count + 1'b00001;
        end   
        else if(count == 5'b10001) begin
            data_out[7:0] <= data_out_sbox[7:0];
            valid_out <= 1'b1;
            count <= count + 1'b00001;
        end    
        else if(count == 5'b10010) begin
            count <= 5'b00000;
            valid_out <= 1'b0;
        end 
    end
    
    sbox sbox(               //S-box look up table
        .clk(clk),
        .data_in(data_in_sbox),
        .data_out(data_out_sbox)
        );
        
    /*
    always@(posedge clk) data_in_delayed <= data_in_buf;  //SFLL input
    assign data_in_sbox[7:0] = {data_in_buf[7]^ll_key[7], data_in_buf[6], data_in_buf[5], data_in_buf[4]^ll_key[5],
                                data_in_buf[3], data_in_buf[2]^ll_key[0], data_in_buf[1]^ll_key[0],data_in_buf[0]};
                                
    sbox sbox(                              //S-box look up table
        .clk(clk),
        .data_in(data_in_sbox),
        .data_out(data_out_sbox)
        );
        
    SFLL SFLL(                              //logic locking
        .data_in(data_in_delayed),
        .data_in_osout(data_out_sbox),
        .data_out_ll(data_out_SFLL),
        .ll_key(ll_key)
    );  
    */
    
endmodule

