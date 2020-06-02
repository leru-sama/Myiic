
`timescale  1ps/1ps

module iic_top 
(
    input       clk,
    input       rst_n,
    input[1:0]  adr_in,
    input[7:0]  data_in,
    input       next,
    input       cs,
    input      scl_i,
    input      sda_i,

    output      scl_oen_n,
    output      sda_oen_n,
    output      scl_o,
    output      sda_o,
    output[7:0] data_out
);

reg[7:0]    TXR;
reg[7:0]    RXR;
reg[7:0]    SR;
reg[7:0]    CTR;
reg[4:0]    count;

parameter avaliable = 8'b00000000;
parameter sending_start = 8'b00001001;
parameter sending_data  = 8'b00001010;
parameter waiting_ack   = 8'b00001000;
parameter sending_end   = 8'b00001100;




wire mod   = CTR[0];
wire start = CTR[1];



reg done_start;
reg sda_start;
//grnerate start signal
always@(posedge scl_o or negedge rst_n) begin
    if(rst_n == 0) begin
        sda_start <= 1;
        done_start <= 0;
    end
    else if(done_start == 0 && start == 1)begin
        sda_start <=  #5 0;
        done_start <= #5 1;
    end
    else if(done_start == 1 && start == 1 && sda_start == 0)
        sda_start <= 1;
end


reg sda_send;
reg done_send;
//generate send data 
always@(negedge scl_o or negedge rst_n) begin
    if(rst_n == 0) begin
        done_send <= 0;
        sda_send  <= 1;
        count     <= 4'b0111;
    end
    else if(count[4] == 0 && done_start) begin
        sda_send <= TXR[count];
        count <= count - 1;
    end 
    else if(count[4] == 1) done_send <= 1;
end

reg ack;
//receive ack
always@(posedge done_send or negedge rst_n) begin
    if(rst_n == 0) ack <= 1'bz;
    else if(sda_i == 0 && scl_i == 1)  ack <= 0;     //no ack
    else if(sda_i == 0 && scl_i == 0)  ack <= 1;     //ack
end

reg scl_end;
reg sda_end;
reg done_end;
//generate end signal
always@(negedge start or negedge rst_n) begin
    if(rst_n == 0) begin
        scl_end <= 1;
        sda_end <= 1;
        done_end <= 0;
    end
    else if(start == 0 && done_send) begin
        scl_end <= 1;
        scl_end <= 0;
        scl_end <= #1 1;
        done_end <= 1;
    end
end


reg[3:0] DIV;          //frequency dive
//generate scl
assign scl_o = DIV[3];
always@(posedge clk or negedge rst_n) begin
    if(rst_n == 0) begin
        DIV <= 0;
    end
    else DIV <= DIV +1;
end


//change SR
always@(posedge clk or negedge rst_n) begin
    if(rst_n == 0) SR <= 8'h00;
    else if(rst_n == 1)begin
         case (SR)
            avaliable:       if(CTR[1] == 1) SR<= sending_start;
            sending_start:   if(done_start)  SR<= sending_data;
            sending_data:    if(done_send)   SR<= waiting_ack;
            waiting_ack: 
                if(CTR[1] == 0)   SR<= sending_end;
                else if(ack)      SR<= sending_start;
                else if(ack == 0) SR<= sending_end;
            sending_end: if(done_end)    SR<= avaliable;
            default:;
         endcase
    end
end

reg[7:0] data_out_r;
assign data_out = data_out_r;
//write registers 
always@(posedge clk or negedge rst_n) begin
    if( rst_n == 0) begin
        CTR <= 0;
        TXR <= 0;
    end 
    else begin
        case (adr_in)
        2'b00: begin
            TXR <= data_in;
            data_out_r <= TXR;
        end
        2'b01: 
            data_out_r <= RXR;
        2'b10:
            data_out_r <= SR;
        2'b11: begin
            CTR <= data_in;
            data_out_r <= CTR;
        end
        default:;
        endcase
    end
end




assign sda_o =  sda_start & sda_end & sda_send;

endmodule  //iic_top