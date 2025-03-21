`timescale 1ns / 1ps

module key_expansion(
input clk,
input rst,
input key_valid,
input [7:0] round_key,
input valid_round,
output reg [7:0] round_out
    );
    
    reg [127:0] round_buf;
    reg [3:0] cnt, cnt_key;
    
    always@(posedge clk or negedge rst) begin
        if(!rst)begin
            round_out <= 8'b0;
            cnt <= 4'b0;
            cnt_key <= 4'b0;
        end
        else begin
            if(key_valid)begin
                round_buf[8*cnt_key +: 8] <= round_key;
                cnt_key <= cnt_key + 4'b0001;
                if(cnt_key == 4'b1111)begin
                    cnt_key <= 4'b0;
                end
            end
            if(valid_round)begin
                round_out <= round_buf[cnt*8 +: 8];
                cnt <= cnt + 4'b0001;
                if(cnt == 4'b1111)begin
                    cnt <= 4'b0000;
                end
            end
        end
    end
    
endmodule
