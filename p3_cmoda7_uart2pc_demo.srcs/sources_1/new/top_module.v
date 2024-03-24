module top_module(
    uart_rxd_out,
    led         ,
    led0_b      ,
    led0_g      ,
    led0_r      ,
    sysclk      ,
    btn         ,
    uart_txd_in 
);
//PIN DEFINATION
//OUTPUT 
output          uart_rxd_out;
output  [1:0]   led         ;
output          led0_b      ;
output          led0_g      ;
output          led0_r      ;
//INPUT
input           sysclk      ;
input   [1:0]   btn         ;
input           uart_txd_in ;

//UNUSED PIN CONFIG
assign led0_b = 1'b1;
assign led0_g = 1'b1;
assign led0_r = 1'b1;

//LED CONFIG
assign led[0] = uart_rxd_out;
assign led[1] = uart_txd_in;

//RESET PIN CONFIG;
wire rstn;
assign rstn = ~btn[0];

//CLOCK TREE CREATION;
wire clk_uart, clk_tx_event;
clock_div clock_div_u0(
    .clkout(clk_uart)       ,
    .rstn(rstn)             ,
    .clksrc(sysclk)
);
defparam clock_div_u0.FREQ_INPUT    = 12_000_000;
defparam clock_div_u0.FREQ_OUTPUT   = 9_600;

clock_div clock_div_u1(
    .clkout(clk_tx_event)        ,
    .rstn(rstn)             ,
    .clksrc(sysclk)
);
defparam clock_div_u0.FREQ_INPUT    = 12_000_000;
defparam clock_div_u0.FREQ_OUTPUT   = 50;

//UART PROTOCAL INSTANCE
localparam      UART_PARITY  = 1'b0;
reg             uart_tx_ready;
wire            uart_tx_vaild;
reg     [7:0]   uart_tx_data;

uart_tx uart_tx_u0(
    .clk(clk_uart),
    .ap_rstn(rstn),
    .ap_ready(uart_tx_ready),
    .ap_vaild(uart_tx_vaild),
    .tx(uart_rxd_out),
    .pairty(UART_PARITY),
    .data(uart_tx_data)
);

reg [7:0] cnter;
//TRANSMIT EVENT:

always @(negedge rstn, posedge uart_tx_vaild)begin
if(!rstn) begin
    cnter <= 8'h00;
end else begin
    cnter <= cnter + 1'b1;
end
end


always @(posedge clk_tx_event, negedge rstn, posedge uart_tx_vaild)begin
    if(!rstn) begin
        uart_tx_data <= 8'h00;
        uart_tx_ready <= 1'b0;
    end else begin
        if(uart_tx_vaild) begin
            uart_tx_ready <= 1'b0;
            uart_tx_data <= cnter;
        end else begin
            uart_tx_ready <= 1'b1;
        end
    end
end

endmodule