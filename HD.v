`timescale 1ns / 1ps

module RES(
input [7:0] key,
input [7:0] data_in,
output reg valid
    );
    
    wire [7:0] correct;
    wire [2:0] count;
    
    assign correct = key ^ data_in; //logic locking key
    assign count = correct[7] + correct[6] + correct[5] + correct[4] +
                correct[3] + correct[2] + correct[1] + correct[0];
                
    always@(*)begin
        case(count)
            3'b010: valid = 1'b1;
            default : valid = 1'b0;
        endcase 
     end         
            
        
    
endmodule
