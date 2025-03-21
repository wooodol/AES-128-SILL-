`timescale 1ns / 1ps

module subbytes(
input [127:0] data_in,
input clk,
input valid_in,
input rst,
input [7:0] key,
output reg [7:0] data_out,
output reg valid_out
    );
    
    reg state;
    reg[4:0] count;
    reg[7:0] data_in_buf; //flattening data_in
    wire [7:0] data_in_sbox, data_out_sbox, data_out_SFLL;
    
    assign data_in_sbox[7:0] = data_in_buf[7:0];
    
    always@(posedge clk or negedge rst)begin
        if(!rst)begin  //reset
            count <= 5'b00000;
            valid_out <= 1'b0;
            state <= 1'b0;
            data_out = 8'b0;
            data_in_buf = 8'b0;
        end
        else if(valid_in == 1'b1)begin
            if(state == 1'b0)begin
                state <= 1'b1;
            end
        end 
        else if(state)begin
           
            data_in_buf[7:0] <= data_in[count*8 +: 8];  
            
            if(count<5'b10001)begin
                if(count>5'b00000)begin
                    data_out[7:0] <= data_out_sbox[7:0];  
                    valid_out <= 1'b1;
                end    
                count <= count+1'b00001;  
            end
            else if(count == 5'b10001) begin
                count <= 5'b00000 ;
                state <= 1'b0;
                valid_out <= 1'b0;
            end 
        end        
    end
    
    sbox sbox(                              //S-box look up table
        .data_in(data_in_sbox),
        .data_out(data_out_sbox)
        );
    
endmodule

