`timescale 1ns / 1ps

module mixcolumn(
input [7:0] data_in,
input clk,
input rst,
input valid_in,
input mod,
output reg valid_out,
output reg [7:0] data_out
    );
    
    reg [127:0] data_buf, data_out_buf;
    reg [31:0] data_col;
    reg [4:0] count, i;
    reg [1:0] state;
    wire [7:0] o1,o2,o3,o4,o5,o6,o7,o8; 
    
    always@(posedge clk or negedge rst)begin
        if(!rst)begin                          //reset
            count <= 5'b0;
            valid_out <= 1'b0;
            data_out <= 8'b0;
            state <= 2'b0;
            data_buf <= 128'b0;
            data_out_buf <= 128'b0;
            data_col <= 32'b0;
            valid_out <= 1'b0;
            i <= 5'b0;
        end
        else begin
            case(mod)
                1'b0:                             //encryption mod
                    if(valid_in) begin
                        if(state == 2'b0)begin
                            data_buf[8*count +: 8] <= data_in;
                            count <= count + 5'd1;
                            if(count == 5'b01111)begin
                                state <= state + 2'b01;
                                count <= 0;
                            end 
                        end 
                    end 
                    else begin
                        if(state == 2'b01)begin // mix column
                            if(count == 0)begin
                                if(i == 0)begin
                                    data_col <= {data_buf[8*count + 96 +: 8],data_buf[8*count  + 64 +: 8]
                                                 ,data_buf[8*count  + 32 +: 8],data_buf[8*count  +: 8]};
                                    count <= count + 5'b00001;
                                end
                            end
                            else if(count > 0)begin
                                if(count<5)begin
                                    data_out_buf[8*i  + 96 +: 8] <= o7 ^ o6 ^ data_buf[8*i  + 32 +: 8] ^ data_buf[8*i  +: 8];
                                    data_out_buf[8*i  + 64 +: 8] <= data_buf[8*i  + 96 +: 8] ^ o5 ^ o4 ^ data_buf[8*i  +: 8];
                                    data_out_buf[8*i  + 32 +: 8]  <= data_buf[8*i  + 96 +: 8] ^ data_buf[8*i + 64 +: 8] ^ o3 ^ o2;
                                    data_out_buf[8*i  +: 8] <= o8 ^ data_buf[8*i + 64 +: 8] ^ data_buf[8*i  + 32 +: 8] ^ o1;
                                    data_col <= {data_buf[8*count + 96 +: 8],data_buf[8*count  + 64 +: 8]
                                                 ,data_buf[8*count  + 32 +: 8],data_buf[8*count  +: 8]};
                                    count <= count + 5'b00001;
                                    i <= i + 5'b00001;
                                    if(count == 5'b00100)begin
                                        count <= 5'b0;
                                        i <= 5'b0;
                                        state <= state + 2'b01;
                                    end 
                                end      
                            end       
                        end
                        else if(state == 2'b10)begin
                             data_out <= data_out_buf[count*8 +: 8];
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
                    
                1'b1: data_out <= 8'b0;       //decryption mod
                
                default : data_out <= 8'b0;    //default
                
            endcase
        end
    end
        
        // GF8 multiplier module                            
        gfmul u0 (.x(data_col[7:0]),.y(8'd2),.out(o1)); //0-2
        gfmul u1 (.x(data_col[7:0]),.y(8'd3),.out(o2)); //0-3
        gfmul u2 (.x(data_col[15:8]),.y(8'd2),.out(o3)); //1-2
        gfmul u3 (.x(data_col[15:8]),.y(8'd3),.out(o4)); //1-3
        gfmul u4 (.x(data_col[23:16]),.y(8'd2),.out(o5)); //2-2
        gfmul u5 (.x(data_col[23:16]),.y(8'd3),.out(o6)); //2-3
        gfmul u6 (.x(data_col[31:24]),.y(8'd2),.out(o7)); //3-2
        gfmul u7 (.x(data_col[31:24]),.y(8'd3),.out(o8)); //3-3                     
                                    
       
endmodule

module gfmul(
    input [7:0]x,
    input [7:0]y,
    output reg [7:0] out
    );
    
    always@(*)begin  
        case(y)
            8'd1: out = x;
            8'd2 :  out = (x[7]? ((x << 1)^8'h1b) : (x << 1));
            8'd3 :  out = (x[7]? (x << 1)^8'h1b : (x << 1))^x;
            default : out = 8'b0;
        endcase 
    end
endmodule 
    

