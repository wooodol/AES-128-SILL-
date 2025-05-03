`timescale 1ns / 1ps
`timescale 1ns / 1ps

module AES_de_tb( );

reg clk;
reg rst;
reg [7:0] data_in;
wire [7:0] data_out_u1;
reg valid_in;
//reg[127:0] memory = 128'h19a09ae93df4c6f8e3e28d48be2b2a08;
reg[127:0] memory = 128'h3902dc19_25dc116a_8409850b_1dfb9732; //cheaper text
reg[127:0] cheaper_key_mem = 128'h2b28ab09_7eaef7cf_15d2154f_16a6883c;
wire valid_out;
wire key_gen_complete;
reg [7:0] ll_key, cheaper_key;
reg mod;
reg start_round;
reg [31:0] cheaper_key_ex;
reg [127:0] cheapertext;
reg o,k;

integer count, cnt, cnt2;

always@(posedge clk)begin
    if(valid_out)begin
        cheapertext[(count*8) +: 8] <= data_out_u1;
        count <= count+1;
    end
end

always@(posedge clk)begin
 $display("time=%0t ns, cheapertext = %h", $time, cheapertext);
 end


AES_128_de u1(
.clk(clk),//
.cheapertext(data_in),//
.start(valid_in),//
.plaintext(data_out_u1),//
.rst(rst),//
.done(valid_out),//
.ll_key(ll_key),//
.mod(mod),//
.cheaper_key(cheaper_key),
.cheaper_key_ex(cheaper_key_ex),//
.start_round(start_round),//
.key_gen_complete(key_gen_complete)
);


initial begin
    clk = 0;
    forever #50 clk = ~clk;
end 

always@(posedge clk)begin
    if(key_gen_complete & o)begin
        k <= 1'b1;
    end
end

always@(posedge clk)begin
    if(k)begin
         data_in <= memory[count*8 +: 8];
         count <= count + 1;
         valid_in <= 1'b1;
        if(count == 15)begin
           count <= count + 1;
        end 
    end
    if(count == 16)begin
        valid_in <= 1'b0;
        k <= 1'b0;
        count <= 0;
        o <= 1'b0;
    end
end

/*
always@(posedge clk)begin
    if(valid_in)begin
        cnt2 <= cnt2 + 1;
        if(cnt2 > 0) begin
            cheaper_key <= cheaper_key_mem[(cnt2-1)*8 +: 8];
        end
        else if(cnt2 == 16)begin
           cnt2 <= cnt2 + 1;
        end 
    end
    if(cnt2 == 17)begin
        cnt2 <= 0;
    end
end
*/

initial begin
    rst = 0;
    ll_key = 8'b01001101; //LL key = 01001101
    mod = 0;
    valid_in = 0;
    data_in = 128'b0;
    count = 0;
    cnt = 0;
    o = 1'b1;
    cnt2 = 0;
    cheaper_key = 8'b0;
    cheaper_key_ex = 32'b0;
    #250
    rst = 1;
    start_round = 1;
    cheaper_key_ex = {cheaper_key_mem[127:120],cheaper_key_mem[95:88],cheaper_key_mem[63:56],cheaper_key_mem[31:24]};
    #100
    cheaper_key_ex = {cheaper_key_mem[119:112],cheaper_key_mem[87:80],cheaper_key_mem[55:48],cheaper_key_mem[23:16]};
    #100
    cheaper_key_ex = {cheaper_key_mem[111:104],cheaper_key_mem[79:72],cheaper_key_mem[47:40],cheaper_key_mem[15:8]};
    #100
    cheaper_key_ex = {cheaper_key_mem[103:96],cheaper_key_mem[71:64],cheaper_key_mem[39:32],cheaper_key_mem[7:0]};
    #200 
    start_round = 0;
end 

endmodule
