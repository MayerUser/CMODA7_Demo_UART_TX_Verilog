// Top-level module declaration with I/O ports for UART communication, LED control, system clock, button input, and UART TX/RX.
module top_module(
    uart_rxd_out,  // UART receiver output signal
    led,           // 2-bit output controlling general-purpose LEDs
    led0_b,        // Output controlling the blue component of LED0
    led0_g,        // Output controlling the green component of LED0
    led0_r,        // Output controlling the red component of LED0
    sysclk,        // System clock input
    btn,           // 2-bit input from button presses
    uart_txd_in    // UART transmitter input signal
);

// I/O declaration section
// Outputs
output          uart_rxd_out; // UART RX data output
output  [1:0]   led;          // General-purpose LEDs
output          led0_b;       // Blue component of LED0
output          led0_g;       // Green component of LED0
output          led0_r;       // Red component of LED0

// Inputs
input           sysclk;       // System clock
input   [1:0]   btn;          // Button inputs
input           uart_txd_in;  // UART TX data input

// Configuration for unused LED pins, setting them to a high state
assign led0_b = 1'b1;
assign led0_g = 1'b1;
assign led0_r = 1'b1;

// LED configuration to display UART TX and RX activity
assign led[0] = uart_rxd_out;
assign led[1] = uart_txd_in;

// Reset pin configuration using one of the button inputs, active low
wire rstn;
assign rstn = ~btn[0];

// Clock tree creation section with instances of a clock divider module to generate different clock domains
// UART clock
wire clk_uart, clk_tx_event, clk_data_proc;
clock_div clock_div_u0(
    .clkout(clk_uart),
    .rstn(rstn),
    .clksrc(sysclk)
);
defparam clock_div_u0.FREQ_INPUT = 12_000_000; // Input frequency to the clock divider
defparam clock_div_u0.FREQ_OUTPUT = 9_600;     // Output frequency for UART operations

// Clock for TX event
clock_div clock_div_u1(
    .clkout(clk_tx_event),
    .rstn(rstn),
    .clksrc(sysclk)
);
defparam clock_div_u1.FREQ_INPUT = 12_000_000; // Input frequency
defparam clock_div_u1.FREQ_OUTPUT = 200;       // Output frequency for TX event timing

// Clock for data processing
clock_div clock_div_u3(
    .clkout(clk_data_proc),
    .rstn(rstn),
    .clksrc(sysclk)
);
defparam clock_div_u3.FREQ_INPUT = 12_000_000; // Input frequency
defparam clock_div_u3.FREQ_OUTPUT = 100;       // Output frequency for data processing

// UART protocol instance for transmitting data with parameter configuration for parity
localparam UART_PARITY = 1'b0; // Parity configuration, 0 for even parity
reg uart_tx_ready;
wire uart_tx_vaild;
reg [7:0] uart_tx_data;

uart_tx uart_tx_u0(
    .clk(clk_uart),
    .ap_rstn(rstn),
    .ap_ready(uart_tx_ready),
    .ap_vaild(uart_tx_vaild),
    .tx(uart_rxd_out),
    .pairty(UART_PARITY),
    .data(uart_tx_data)
);

// Implements a 16-bit auto-incrementing counter that transmits data to a PC.
// Since the UART protocol is limited to transmitting 8 bits per frame,
// a "odd" register is employed to divide the 16-bit counter into two sections,
// allowing for sequential transmission of each 8-bit segment.
reg [15:0] cnter;
reg odd;
always @(negedge rstn or posedge clk_data_proc) begin
    if (!rstn) begin
        cnter <= 8'h00;
        uart_tx_data <= 8'h00;
        odd <= 1'b0;
    end else begin
        odd <= ~odd;
        uart_tx_data <= odd ? cnter[15:8] : cnter[7:0];
        cnter <= odd ? cnter + 1'b1 : cnter;
        //You can replace cnter with your random number generator;
        //e.g. a 16 bits wire [15:0] rng_number;
        // cnter <= odd ? rng_number : ; //Allow you to transmit number to PC;    
    end
end

// Control logic for UART transmission readiness based on TX event clock and reset signal
always @(posedge clk_tx_event or negedge rstn) begin
    if (!rstn) begin
        uart_tx_ready <= 1'b0;
    end else begin
        if (uart_tx_vaild) begin
            uart_tx_ready <= 1'b0;
        end else begin
            uart_tx_ready <= 1'b1;
        end
    end
end

endmodule
