`timescale 1ns / 1ps

module invaddroundkey1st(
input [7:0] data_in,
input [7:0] round_key,
input rst,
input clk,
input valid_in,
output reg valid_out, 
output reg [7:0] data_out
    );
    
    reg [3:0] state, cnt;
    reg [7:0] data_buf;
    reg [127:0] data_out_buf;
    
    always@(posedge clk) begin
        if(!rst)begin
            state <= 4'b0;
            cnt <= 4'b0;
            data_buf <= 8'b0;
            valid_out <= 1'b0;
            data_out <= 8'b0;
        end
        else begin
            case(state)
                4'b0000: begin      //state == 0
                    if(valid_in) begin
                        data_buf <= data_in;
                        cnt <= cnt + 4'b0001;
                        if(cnt > 4'b0000)begin
                            data_out_buf[(cnt-1)*8 +: 8] <= data_buf ^ round_key;
                            if(cnt == 4'b1111) begin
                                cnt <= 4'b0000;
                                state <= 4'b0001;
                            end
                        end
                    end
                end
                
                4'b0001: begin
                    data_out_buf[127:120] <= data_buf ^ round_key;
                    state <= 4'b0010;
                end
                
                4'b0010: begin 
                    valid_out <= 1'b1;
                    data_out <= data_out_buf[8*cnt +: 8];
                    cnt <= cnt + 4'b0001;
                    if(cnt == 4'b1111)begin
                        state <= 4'b0011;
                        cnt <= 4'b0000;
                    end
                end
                
                4'b0011: begin
                    valid_out <= 1'b0;
                    state <= 4'b0000;
                end
                
                default : begin    //default
                    state <= 4'b0;
                    cnt <= 4'b0;
                    data_buf <= 8'b0;
                    data_out <= 8'b0;
                end
                
            endcase
        end
    end
    
endmodule
