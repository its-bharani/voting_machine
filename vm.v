`timescale 1ns/1ps
module vm(
    input clock, on_off,
    input p1, p2, p3, p4,  // Vote buttons
    input win,             // Display winner button
    input s1, s2,          // Selection buttons for displaying votes
    output reg [6:0] seg,  // 7-segment display data
    output reg [7:0] an    // Register to select active 7-segment display
);
    wire led;
    reg [3:0] votes_p1 = 0;
    reg [3:0] votes_p2 = 0;
    reg [3:0] votes_p3 = 0;
    reg [3:0] votes_p4 = 0;
    reg [3:0] selected_votes = 0;

    parameter SEG_0 = 7'b0000001;
    parameter SEG_1 = 7'b1001111;
    parameter SEG_2 = 7'b0010010;
    parameter SEG_3 = 7'b0000110;
    parameter SEG_4 = 7'b1001100;
    parameter SEG_5 = 7'b0100100;
    parameter SEG_6 = 7'b0100000;
    parameter SEG_7 = 7'b0001111;
    parameter SEG_8 = 7'b0000000;
    parameter SEG_9 = 7'b0000100;
    parameter SEG_OFF = 7'b1111111;

    userclock u1(clock, led);

    always @(posedge led) begin
        if (on_off) begin
            votes_p1 <= 0;
            votes_p2 <= 0;
            votes_p3 <= 0;
            votes_p4 <= 0;
            seg <= SEG_OFF;
            an <= 8'b11111111;
        end else begin
          an <= 8'b11111110; // Rightmost 7-seg for votes display
            if (p1) votes_p1 <= votes_p1 + 1;
            if (p2) votes_p2 <= votes_p2 + 1;
            if (p3) votes_p3 <= votes_p3 + 1;
            if (p4) votes_p4 <= votes_p4 + 1;
            
            if (~s1 & ~s2) selected_votes <= votes_p1;
            else if (~s1 & s2) selected_votes <= votes_p2;
            else if (s1 & ~s2) selected_votes <= votes_p3;
            else if (s1 & s2) selected_votes <= votes_p4;

            case (selected_votes)
                0: seg <= SEG_0;
                1: seg <= SEG_1;
                2: seg <= SEG_2;
                3: seg <= SEG_3;
                4: seg <= SEG_4;
                5: seg <= SEG_5;
                6: seg <= SEG_6;
                7: seg <= SEG_7;
                8: seg <= SEG_8;
                9: seg <= SEG_9;
                default: seg <= SEG_OFF;
            endcase
            
            
            if (win) begin
                an <= 8'b01111111; // Leftmost 7-seg for winner display
                if ((votes_p1 == votes_p2 && votes_p1 == votes_p3 && votes_p1 == votes_p4) ||
                    (votes_p1 == votes_p2 && votes_p1 > votes_p3 && votes_p1 > votes_p4) ||
                    (votes_p1 == votes_p3 && votes_p1 > votes_p2 && votes_p1 > votes_p4) ||
                    (votes_p1 == votes_p4 && votes_p1 > votes_p2 && votes_p1 > votes_p3) ||
                    (votes_p2 == votes_p3 && votes_p2 > votes_p1 && votes_p2 > votes_p4) ||
                    (votes_p2 == votes_p4 && votes_p2 > votes_p1 && votes_p2 > votes_p3) ||
                    (votes_p3 == votes_p4 && votes_p3 > votes_p1 && votes_p3 > votes_p2)) begin
                    seg <= SEG_0; // Display 0 for tie
                end else if (votes_p1 >= votes_p2 && votes_p1 >= votes_p3 && votes_p1 >= votes_p4) begin
                    seg <= SEG_1;
                end else if (votes_p2 >= votes_p1 && votes_p2 >= votes_p3 && votes_p2 >= votes_p4) begin
                    seg <= SEG_2;
                end else if (votes_p3 >= votes_p1 && votes_p3 >= votes_p2 && votes_p3 >= votes_p4) begin
                    seg <= SEG_3;
                end else if (votes_p4 >= votes_p1 && votes_p4 >= votes_p2 && votes_p4 >= votes_p3) begin
                    seg <= SEG_4;
                end else begin
                    seg <= SEG_OFF;
                end
            end
        end
    end
endmodule

module userclock (input clock, output led);
    reg [25:0] count = 0;
    reg clock_out=0;
    always @(posedge clock) begin
        count <= count + 1;
        if (count == 9500000) begin
            count <= 0;
            clock_out<=~clock_out;
            end
            end
            assign led = clock_out;
endmodule
