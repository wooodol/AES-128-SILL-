`timescale 1ns / 1ps

module invmixcolumn(
input [7:0] data_in,
input clk,
input rst,
input valid_in,
input mod,
output reg valid_out, round_o,
output reg [7:0] data_out
    );

    reg [127:0] data_buf, data_out_buf;
    reg [31:0] data_col;
    reg [4:0] count, i;
    reg [1:0] state;

    wire [7:0] o[0:15];
    wire [7:0] s0, s1, s2, s3;
    assign s0 = data_col[31:24];
    assign s1 = data_col[23:16];
    assign s2 = data_col[15:8];
    assign s3 = data_col[7:0];

    always@(posedge clk)begin
        if(!rst)begin
            count <= 5'b0;
            valid_out <= 1'b0;
            data_out <= 8'b0;
            state <= 2'b0;
            data_buf <= 128'b0;
            data_out_buf <= 128'b0;
            data_col <= 32'b0;
            i <= 5'b0;
            round_o <= 1'b0;
        end
        else begin
            case(mod)
                1'b0: begin  // encryption mod
                    if(state == 2'b00)begin
                        if(valid_in)begin
                            data_buf[8*count +: 8] <= data_in;
                            count <= count + 5'd1;
                            if(count == 5'd15)begin
                                state <= 2'b01;
                                count <= 5'd0;
                            end
                        end 
                    end 
                    else if(state == 2'b01)begin // mix column
                        if(count == 0)begin
                            if(i == 0)begin
                                data_col <= {data_buf[8*count + 96 +: 8],data_buf[8*count  + 64 +: 8]
                                             ,data_buf[8*count  + 32 +: 8],data_buf[8*count  +: 8]};
                                count <= count + 5'b00001;
                            end
                        end
                        else if(count > 0)begin
                            if(count<5)begin
                                data_out_buf[8*i + 96 +: 8] <= o[0] ^ o[1] ^ o[2] ^ o[3];
                                data_out_buf[8*i + 64 +: 8] <= o[4] ^ o[5] ^ o[6] ^ o[7];
                                data_out_buf[8*i + 32 +: 8] <= o[8] ^ o[9] ^ o[10] ^ o[11];
                                data_out_buf[8*i + 0  +: 8] <= o[12] ^ o[13] ^ o[14] ^ o[15];
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
                    else if(state == 2'b10)begin  // output
                        data_out <= data_out_buf[count*8 +: 8];
                        count <= count + 5'd1;
                        valid_out <= 1'b1;
                        if(count == 5'd15)begin
                            state <= 2'b11;
                            count <= count + 5'd1;
                        end 
                    end
                    else if(state == 2'b11)begin  // final state
                        if(count == 5'd16)begin
                            valid_out <= 1'b0;
                            count <= 5'd17;
                            round_o <= 1;
                        end
                        else if(count == 5'd17)begin
                            state <= 2'b00;
                            count <= 5'd0;
                            round_o <= 0;
                        end
                    end
                end

                1'b1: data_out <= 8'b0;  // decryption mod

                default: data_out <= 8'b0;
            endcase
        end
    end

    // GF8 multiplier module                             
    gfmul g0  (.x(s0), .y(8'h0e), .out(o[0]));
    gfmul g1  (.x(s1), .y(8'h0b), .out(o[1]));
    gfmul g2  (.x(s2), .y(8'h0d), .out(o[2]));
    gfmul g3  (.x(s3), .y(8'h09), .out(o[3]));

    gfmul g4  (.x(s0), .y(8'h09), .out(o[4]));
    gfmul g5  (.x(s1), .y(8'h0e), .out(o[5]));
    gfmul g6  (.x(s2), .y(8'h0b), .out(o[6]));
    gfmul g7  (.x(s3), .y(8'h0d), .out(o[7]));

    gfmul g8  (.x(s0), .y(8'h0d), .out(o[8]));
    gfmul g9  (.x(s1), .y(8'h09), .out(o[9]));
    gfmul g10 (.x(s2), .y(8'h0e), .out(o[10]));
    gfmul g11 (.x(s3), .y(8'h0b), .out(o[11]));

    gfmul g12 (.x(s0), .y(8'h0b), .out(o[12]));
    gfmul g13 (.x(s1), .y(8'h0d), .out(o[13]));
    gfmul g14 (.x(s2), .y(8'h09), .out(o[14]));
    gfmul g15 (.x(s3), .y(8'h0e), .out(o[15]));

endmodule
