`timescale 1ns / 1ps

module SFLL(
input [7:0] key,
input [7:0] data_in_sbox,
input [7:0] data_out_sbox,
output reg [7:0] data_out
    );
    
    wire [7:0] data_stripped;
    wire valid;
    
    cubestripper cubestripper(
        .data_in(data_in_sbox),
        .data_sbox(data_out_sbox),
        .data_out(data_stripped)
    ); 
    
    RES RES(
        .data_in(data_in_sbox),
        .key(key),
        .valid(valid)
    );
    
    always@(*)begin
        if(valid == 1'b0)begin //data modulation
            data_out = data_stripped;
        end  
        else if(valid == 1'b1)begin //data pass
            data_out[7] = data_stripped[7]^1'b1;
            data_out[6] = data_stripped[6]^1'b1;
            data_out[5] = data_stripped[5]^1'b1;
            data_out[4] = data_stripped[4]^1'b1;
            data_out[3] = data_stripped[3]^1'b1;
            data_out[2] = data_stripped[2]^1'b1;
            data_out[1] = data_stripped[1]^1'b1;
            data_out[0] = data_stripped[0]^1'b1;
        end 
        else begin
            data_out = 8'b0;
        end
    end

endmodule
