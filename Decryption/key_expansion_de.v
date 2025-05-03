`timescale 1ns / 1ps

module key_expansion_de(
input clk,
input rst,
input key_valid,
input [31:0] cheaper_key,
input [3:0] ll_key,
input valid_round,
output reg [7:0] round_out,
output reg key_gen_complete
    );
    
    reg gen_complete;
    wire [7:0] data_in_sbox1, data_out_sbox1;
    wire [7:0] data_in_sbox2, data_out_sbox2;
    wire [7:0] data_in_sbox3, data_out_sbox3;
    wire [7:0] data_in_sbox4, data_out_sbox4;
    
    reg gen; //enable key generate
    reg [3:0] cnt, round, round_send;
    reg send_buff;
    reg [127:0] key_buff;
    reg [1407:0] key;
    reg re_gen;
    
    
    //LL circuit---------------------------------------------------------------------
    wire encrypt_out, inter_out;
    reg inter1, inter2, encrypt1, encrypt2;
    wire [2:0] count1, count2;
    wire [2:0] correct1, correct2;
    
    assign sendin1 = key_gen_complete ^ encrypt_out;
    assign sendin2 = valid_round ^ inter_out;
    wire [2:0] cnt1, cnt2;
    
    assign cnt1 = cnt[2:0];
    assign cnt2 = cnt[3:1];
    
    //encryption
    always@(*)begin
        if(cnt1 == 3'b101)begin
            encrypt1 = 1'b1;
        end
        else encrypt1 = 1'b0;
    end
    
    assign correct1 = ll_key[2:0] ^ cnt[2:0]; //logic locking key
    assign count1 = correct1[2] + correct1[1] + correct1[0];
    assign encrypt_out = encrypt1 ^ encrypt2;
                
    always@(*)begin
        case(count1)
            3'b000: encrypt2 = 1'b1;
            default : encrypt2 = 1'b0;
        endcase 
     end 
    //interference
    always@(*)begin
        if(cnt2 == 3'b110)begin
            inter1 = 1'b1;
        end
        else inter1 = 1'b0;
    end
    
    assign correct2 = ll_key[3:1] ^ cnt[3:1]; //logic locking key
    assign count2 = correct2[2] + correct2[1] + correct2[0];
    assign inter_out = inter1 ^ inter2;
                
    always@(*)begin
        case(count2)
            3'b000: inter2 = 1'b1;
            default : inter2 = 1'b0;
        endcase 
     end    
    //----------------------------------------------------------------------------------
    

    assign send = sendin1 & sendin2;
    
    /*
    assign send = key_gen_complete & valid_round;
    */
    
    /*
    assign negedge_send = (send_buff & !send);
    (* DONT_TOUCH = "true" *) always@(posedge clk)begin
        if(negedge_send & rst)begin
            re_gen <= 1'b1;
        end
    end
    */
    
    assign data_in_sbox1 = gen? key[103:96] : key_buff[103:96];
    assign data_in_sbox2 = gen? key[71:64] : key_buff[71:64];
    assign data_in_sbox3 = gen? key[39:32] : key_buff[39:32];
    assign data_in_sbox4 = gen? key[7:0] : key_buff[7:0];
    
    (* DONT_TOUCH = "true" *) always@(posedge clk)begin // buffer for detect negedge of 'send'
        send_buff <= send;
    end    
    
    (* DONT_TOUCH = "true" *) always@(posedge clk or negedge rst)begin //key set
        if(!rst)begin
            key_buff <= 127'b0;
            key <= 1408'b0;
            cnt <= 4'b0;
            gen <= 1'b0;
            re_gen <= 1'b0;
            gen_complete <= 1'b0;
            send_buff <= 1'b0;
            round <= 4'b0;
            round_send <= 4'b1010;
            key_gen_complete <= 1'b0;
        end
        else begin
            if(key_valid)begin
                case(cnt)
                    4'b0000: begin
                        {key[127:120],key[95:88],key[63:56],key[31:24]} <= cheaper_key;
                        cnt <= cnt + 1;
                    end
                    4'b0001: begin
                        {key[119:112],key[87:80],key[55:48],key[23:16]} <= cheaper_key;
                        cnt <= cnt + 1;
                    end
                    4'b0010: begin
                        {key[111:104],key[79:72],key[47:40],key[15:8]} <= cheaper_key;
                        cnt <= cnt + 1;
                    end
                    4'b0011: begin
                        {key[103:96],key[71:64],key[39:32],key[7:0]} <= cheaper_key;
                        cnt <= cnt + 1;
                    end
                    4'b0100: begin
                        key_buff <= key[127:0];
                        cnt <= 0;
                        gen <= 1'b1;
                    end
                    default: begin
                        {key[127:120],key[95:88],key[63:56],key[31:24]} <= 32'b0; //col1
                        {key[119:112],key[87:80],key[55:48],key[23:16]} <= 32'b0; //col2
                        {key[111:104],key[79:72],key[47:40],key[15:8]} <= 32'b0;  //col3
                        {key[103:96],key[71:64],key[39:32],key[7:0]} <= 32'b0;    //col4
                        cnt <= 0;
                        gen <= 1'b0;
                    end
                endcase 
            end
            if(gen | gen_complete)begin
                case(cnt)
                    4'b0000: begin
                        cnt <= cnt + 1;
                    end
                    4'b0001: cnt <= cnt + 1;
                    4'b0010: begin
                       {key_buff[127:120],key_buff[95:88],key_buff[63:56],key_buff[31:24]} <=
                        
                        {key_buff[127:120] ^ rcon(round+1) ^ data_out_sbox2, key_buff[95:88] ^ 8'b0 ^ data_out_sbox3,
                         key_buff[63:56] ^ 8'b0 ^ data_out_sbox4, key_buff[31:24] ^ 8'b0 ^ data_out_sbox1};    
                         cnt <= cnt + 1;
                    end
                    4'b0011: begin
                        {key_buff[119:112],key_buff[87:80],key_buff[55:48],key_buff[23:16]} <= 
                        
                        {key_buff[119:112] ^ key_buff[127:120], key_buff[87:80] ^ key_buff[95:88],
                         key_buff[55:48] ^ key_buff[63:56], key_buff[31:24] ^ key_buff[23:16]};
                         cnt <= cnt + 1;
                    end
                    4'b0100:begin
                        {key_buff[111:104],key_buff[79:72],key_buff[47:40],key_buff[15:8]} <=
                        
                        {key_buff[111:104] ^ key_buff[119:112], key_buff[79:72] ^ key_buff[87:80],
                         key_buff[47:40] ^ key_buff[55:48], key_buff[15:8] ^ key_buff[23:16]};
                         cnt <= cnt + 1;
                    end
                    4'b0101:begin
                        {key_buff[103:96],key_buff[71:64],key_buff[39:32],key_buff[7:0]} <=
                        
                        {key_buff[103:96] ^ key_buff[111:104], key_buff[71:64] ^ key_buff[79:72],
                         key_buff[39:32] ^ key_buff[47:40], key_buff[7:0] ^ key_buff[15:8]};
                         cnt <= cnt + 1;
                    end
                    4'b0110:begin
                         key[((round+1)*128) +: 128] <= key_buff;
                         cnt <= 4'b0;
                         if(round < 4'b1001)begin
                             gen_complete <= 1'b1;
                             gen <= 1'b0;
                             re_gen <= 1'b0;
                             round <= round + 1;
                         end
                         else begin
                             gen_complete <= 1'b0;
                             gen <= 1'b0;
                             re_gen <= 1'b0;
                             round <= 4'b0;
                             key_gen_complete <= 1'b1;
                         end
                    end
                    default: begin
                        {key[127:120],key[95:88],key[63:56],key[31:24]} <= 32'b0; //col1
                        {key[119:112],key[87:80],key[55:48],key[23:16]} <= 32'b0; //col2
                        {key[111:104],key[79:72],key[47:40],key[15:8]} <= 32'b0;  //col3
                        {key[103:96],key[71:64],key[39:32],key[7:0]} <= 32'b0;    //col4
                        cnt <= 4'b0;
                        gen_complete <= 1'b0;
                        gen <= 1'b0;
                        re_gen <= 1'b0;
                    end
                endcase
            end
            if(send)begin
                cnt <= cnt+1;
                round_out <= key[(round_send*128) + cnt*8 +:8];
                if(cnt == 4'b1111) begin
                    cnt <= 4'b0;
                    round_send <= round_send - 1;
                    if(round_send == 4'b0000)begin
                        round_send <= 4'b0;
                    end
                end
            end
            else begin
                round_out <= 8'b0;
            end
        end
    end
    
    (* DONT_TOUCH = "true" *) function [7:0] rcon;
    input [3:0] round;
    begin
        case(round)
            4'd1: rcon = 8'b00000001;
            4'd2: rcon = 8'b00000010;
            4'd3: rcon = 8'b00000100;
            4'd4: rcon = 8'b00001000;
            4'd5: rcon = 8'b00010000;
            4'd6: rcon = 8'b00100000;
            4'd7: rcon = 8'b01000000;
            4'd8: rcon = 8'b10000000;
            4'd9: rcon = 8'b00011011;
            4'd10: rcon = 8'b00110110;
            default: rcon = 8'b00000000;
        endcase
    end
    endfunction
    
    (* DONT_TOUCH = "true" *) sbox u1(                              //S-box look up table
        .clk(clk),
        .data_in(data_in_sbox1),
        .data_out(data_out_sbox1)
        );
        
    (* DONT_TOUCH = "true" *) sbox u2(                              //S-box look up table
        .clk(clk),
        .data_in(data_in_sbox2),
        .data_out(data_out_sbox2)
        );
        
    (* DONT_TOUCH = "true" *) sbox u3(                              //S-box look up table
        .clk(clk),
        .data_in(data_in_sbox3),
        .data_out(data_out_sbox3)
        );
        
    (* DONT_TOUCH = "true" *) sbox u4(                              //S-box look up table
        .clk(clk),
        .data_in(data_in_sbox4),
        .data_out(data_out_sbox4)
        );
    
endmodule
