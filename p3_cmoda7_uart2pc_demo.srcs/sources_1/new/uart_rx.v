// Module Name: uart_rx
// Date : 2024/03/24
// Version : V0.1
// Author : Maoyang
// Description: Implements a UART receiver that decodes incoming serial data according to the UART protocol.
// This module supports configurable parity checking and handles the reception of data framed with start,
// stop, and optional parity bits. It signals the end of reception and validity of the received data.

// Inputs:
// clk: System clock signal for synchronizing the reception process.
// ap_rstn: Asynchronous, active low reset signal to initialize or reset the module's internal states.
// ap_ready: Input signal indicating the host is ready to start data reception. 
// rx: Serial input receiving the encoded data along with start, stop, and optional parity bits.
// parity: Input signal to enable (when high) or disable (when low) parity bit checking during reception.

// Outputs:
// ap_vaild: Output signal that indicates the completion and validity of data reception.
// data: 8-bit output where the received data is stored. In case of a parity error, it might output
//       an undefined value (8'hzz) to indicate error.

// Local Parameters:
// FSM_IDLE, FSM_STAR, FSM_TRSF, FSM_PARI, FSM_STOP: Represent the states of the finite state machine (FSM)
// controlling the UART reception process, handling the start bit, data bits, optional parity bit, and stop bit.

// Internal Registers:
// fsm_statu: Holds the current state of the FSM.
// fsm_next: Determines the next state of the FSM based on current state and input signals.
// cnter: Counter used during the data reception state to index through the receiving bits.
// buffer: Temporary storage for the received bits before they are moved to the 'data' output register.
// pairty_err: Flag indicating a parity error during reception.

// Behavioral Blocks:
// 1. fsm statu transfer: Sequential logic block that updates the current state of the FSM on each positive clock edge
//    or on the negative edge of ap_rstn. Resets to FSM_IDLE on reset.
// 2. fsm next statu conditional transfer: Combinatorial logic block that determines the next state of the FSM based on
//    current conditions like ap_ready signal, rx input, and the counter value.
// 3. fsm statu action: Sequential logic block performing actions based on the current FSM state, including storing received
//    bits into the buffer, checking for parity errors if parity checking is enabled, and transferring the received data
//    to the output 'data' register upon successful reception or signaling a parity error.


module uart_rx(
    input   clk,
    input   ap_rstn,
    input   ap_ready,
    output  reg ap_vaild,
    input   rx,
    input   parity,
    output  reg [7:0] data    
);

localparam  FSM_IDLE = 3'b000,
            FSM_STAR = 3'b001,
            FSM_TRSF = 3'b010,
            FSM_PARI = 3'b011,
            FSM_STOP = 3'b100;

reg [2:0] fsm_statu;
reg [2:0] fsm_next;
reg [2:0] cnter;

//fsm statu transfer;
always @(posedge clk, negedge ap_rstn) begin
    if (!ap_rstn)begin
        fsm_statu <= FSM_IDLE;
    end else begin
        fsm_statu <= fsm_next;
    end
end

//fsm next statu conditional transfer;
always @(*)begin
    if(!ap_rstn)begin
        fsm_next <= FSM_IDLE;
    end else begin
        case(fsm_statu)
            FSM_IDLE:begin 
                fsm_next <= (ap_ready) ? FSM_STAR : FSM_IDLE;
            end
            FSM_STAR:begin 
                fsm_next <= (!rx) ? FSM_TRSF: FSM_STAR ;
            end
            FSM_TRSF:begin 
                fsm_next <= (cnter == 3'h7) ? (parity?FSM_PARI:FSM_STOP) : FSM_TRSF;
                // fsm_next <= (cnter == 3'h7) ? FSM_STOP : FSM_TRSF;
            end
            FSM_PARI: fsm_next <= FSM_STOP;
            FSM_STOP:begin 
                fsm_next <= (!ap_ready && rx) ? FSM_IDLE : FSM_STOP;
            end
            default: fsm_next <= FSM_IDLE;
        endcase
    end
end

reg [7:0] buffer;
//fsm statu action
reg pairty_err;
always @(posedge clk, negedge ap_rstn) begin
    if(!ap_rstn) begin
        cnter <= 3'h0;
        data <= 8'h00;
        pairty_err <= 1'b0;
    end
    else begin
        case (fsm_statu)
            FSM_IDLE: begin
                ap_vaild <= 1'b0;
            end
            FSM_STAR: begin 
                buffer <= 8'h00;
                cnter <= 3'h0;
            end
            FSM_TRSF: begin
                cnter <= cnter + 1'b1;
                buffer <= {rx,buffer[7:1]};
            end
            FSM_PARI: begin
                pairty_err <= (rx == (^buffer)); //Parity Check - ODD Check;
            end
            FSM_STOP: begin
                ap_vaild <= 1'b1;
                data <= (pairty_err)? 8'hzz:buffer;
            end
            default: ;
        endcase
    end
end

endmodule