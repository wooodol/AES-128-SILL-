`timescale 1ns / 1ps

module invshiftrows(
input [7:0] data_in,
input clk,
input valid_in,
input rst,
output reg [7:0] data_out,
output reg valid_out
    );
    
    reg [1:0] state;
    reg[4:0] count;
    reg[127:0] data_buf; //buffer for data_in
    
    always@(posedge clk or negedge rst)begin
        if(!rst)begin       //reset
            state <= 2'b0;
            valid_out <= 1'b0;
            data_out <= 8'b0;
            count <= 5'b0;
            data_buf <= 128'b0;
        end 
        else if(valid_in) begin
            if(state == 1'b0)begin
                data_buf[count*8 +: 8] <= data_in; //accumulate data
                count <= count + 5'b00001;
                if(count == 5'b01111)begin
                    count <= 5'b0;
                    state <= 2'b01;
                end 
            end 
        end    
        else begin
            if(state == 2'b01)begin
                data_buf[127:0]<= //shift rows
                        {data_buf[127:96],
                        data_buf[71:64],data_buf[95:88],data_buf[87:80],data_buf[79:72],
                        data_buf[47:40],data_buf[39:32],data_buf[63:56], data_buf[55:48],
                        data_buf[23:16],data_buf[15:8], data_buf[7:0],data_buf[31:24]};
                        state <= state + 2'b01;
            end
            else if(state == 2'b10)begin
                 data_out <= data_buf[count*8 +: 8];
                 count <= count + 5'b00001;
                 valid_out <= 1'b1;
                 if(count == 5'b01111)begin
                    state <= 2'b00;
                    count <= count + 5'b00001;
                end 
            end
            if(count == 5'b10000)begin
                valid_out <= 1'b0;
                count <= 5'b0;
            end
        end
   end
    
endmodule
