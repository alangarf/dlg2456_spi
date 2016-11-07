`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Alan Garfield <alan@fromorbit.com>
//
// Create Date:     14:26:42 02/20/2011
// Design Name:     DLG2416 to SPI
// Module Name:     spidlg
// Project Name:
// Target Devices:  XC9536
// Description:     Creates an SPI interface to the 8bit DLG2416 display
//
// Revision:        1.0
//
//////////////////////////////////////////////////////////////////////////////////
module spidlg(
    input Clk,
    input Dclk,
    input Din,
    input Dlatch,
    output [6:0] Dout,
    output [5:0] Addr,
    output CLR,
    output WR
);

    reg clear;
    reg write_latch;

    reg [3:0] address;
    reg [8:0] sr;
    reg [2:0] state;

    // Commands
    parameter CLEAR=0, LOAD=1, LOAD_ADV=2, GOTO_POS=3;

    // States
    parameter S_IDLE=0, S_CLEAR=1, S_LOAD=2, S_WR=3, S_LOAD_ADV=4, S_ADV_WR=5, S_GOTO_POS=6;

    // Shift Register
    always @(posedge Dclk)
    begin
        sr[8:1] <= sr[7:0];
        sr[0] <= Din;
    end

    // State machine
    always @(posedge Clk or posedge Dlatch)
    begin
        if (Dlatch)
            case (sr[8:7])
                CLEAR:
                    state = S_CLEAR;
                LOAD:
                    state = S_LOAD;
                LOAD_ADV:
                    state = S_LOAD_ADV;
                GOTO_POS:
                    state = S_GOTO_POS;
                default:
                    state = S_IDLE;
            endcase
        else
            case (state)
                S_IDLE: begin
                    address <= address;
                    state = S_IDLE;
                    end
                S_CLEAR: begin
                    address <= 0;
                    state = S_IDLE;
                    end
                S_GOTO_POS: begin
                    address <= sr[3:0];
                    state = S_IDLE;
                    end
                S_LOAD: begin
                    address <= address;
                    state = S_WR;
                    end
                S_WR: begin
                    address <= address;
                    state = S_IDLE;
                    end
                S_LOAD_ADV: begin
                    address <= address;
                    state = S_ADV_WR;
                    end
                S_ADV_WR: begin
                    address <= address + 1;
                    state = S_IDLE;
                    end
            endcase
    end

    // Latch and Clear control
    always @(state)
    begin
        case (state)
            default: begin
                    clear <= 0;
                    write_latch <= 0;
                end
            S_GOTO_POS: begin
                    clear <= 0;
                    write_latch <= 0;
                end
            S_LOAD_ADV: begin
                    clear <= 0;
                    write_latch <= 0;
                end
            S_CLEAR: begin
                    clear <= 1;
                    write_latch <= 0;
                end
            S_WR: begin
                    clear <= 0;
                    write_latch <= 1;
                end
            S_ADV_WR: begin
                    clear <= 0;
                    write_latch <= 1;
                end
        endcase
    end

assign Dout = sr[6:0];
assign CLR = ~clear;
assign WR = ~write_latch;
assign Addr[5] = ~address[3];
assign Addr[4] = ~address[2];
assign Addr[3] = address[3];
assign Addr[2] = address[2];
assign Addr[1] = ~address[1];
assign Addr[0] = ~address[0];

endmodule
