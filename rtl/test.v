`timescale 1ps/1ps

module test;
reg clk;
reg rst_n;
reg[1:0] adr;
reg[7:0] data_in;
wire    scl_oen_n;
wire    sda_oen_n;
wire    scl_o;
wire    sda_o;
wire    scl;
wire    sda;
reg scl_i;
reg sda_i;
assign scl = scl_oen_n? 1'bz : scl_o;
assign sda = sda_oen_n? 1'bz : sda_o;

pullup P1(scl);
pullup P2(sda);

initial begin
    clk = 0;
    rst_n = 0;
    #10
    rst_n = 1;
    #10
    adr <= 2'b00;
    data_in <= 8'b11011000;
    #10
    adr <= 2'b11;
    data_in <= 8'b00000010;
    #320
    scl_i <= 1;
    sda_i <= 1;
    sda_i <= #5 0;
    #10
    adr <= 2'b11;
    data_in <= 8'b00000000;

end
always #1 clk <= ~clk;



iic_top master(
    .clk(clk),
    .rst_n(rst_n),
    .adr_in(adr),
    .data_in(data_in),
    .scl_oen_n(scl_oen_n),
    .sda_oen_n(sda_oen_n),
    .scl_o(scl_o),
    .sda_o(sda_o),
    .scl_i(scl_i),
    .sda_i(sda_i)
);



endmodule // test