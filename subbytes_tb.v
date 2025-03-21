`timescale 1ns / 1ps

module subbytes_tb( );

reg clk;
reg rst;
reg [127:0] data_in;
reg [7:0] round_key;
wire [7:0] data_out;
reg valid_in;
reg[127:0] memory = 128'h19a09ae93df4c6f8e3e28d48be2b2a08;
reg[127:0] round_mem = 128'ha088232afa54a36cfe2c397617b13905;
wire valid_out;
reg [7:0] key;
reg mod;
reg start_round;


AES_128 u1(
.clk(clk),
.data_in(data_in),
.start(valid_in),
.data_out(data_out),
.rst(rst),
.valid_out(valid_out),
.key(key),
.mod(mod),
.round_key(round_key),
.start_round(start_round)
);

/**
subbytes u1(
.clk(clk),
.data_in(data_in),
.valid_in(valid_in),
.data_out(data_out),
.rst(rst),
.valid_out(valid_out)
);*/

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end 

initial begin
    rst = 0;
    key = 8'b01001010;
    mod = 0;
    valid_in = 0;
    data_in = 128'b0;
    #25
    rst = 1;
    valid_in = 1;
    start_round = 1;
    data_in = memory;
    round_key = 8'h05;
    #10
    valid_in = 0;
    round_key = 8'h39;
    #10
    round_key = 8'hb1;
    #10
    round_key = 8'h17;
    #10
    round_key = 8'h76;
    #10
    round_key = 8'h39;
    #10
    round_key = 8'h2c;
    #10
    round_key = 8'hfe;
    #10
    round_key = 8'h6c;
    #10
    round_key = 8'ha3;
    #10
    round_key = 8'h54;
    #10
    round_key = 8'hfa;
    #10
    round_key = 8'h2a;
    #10
    round_key = 8'h23;
    #10
    round_key = 8'h88;
    #10
    round_key = 8'ha0;
    #10
    start_round = 0;
end 

endmodule
