`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 19:24:46
// Design Name: 
// Module Name: generic_timer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module generic_timer #(
    parameter COUNT_WIDTH = 32,
    parameter TIMER_COUNT = 100
)
(
    input wire clk,
    input wire rst,

    input wire enable,

    output reg timer_done
);

reg [COUNT_WIDTH-1:0] counter;

always @(posedge clk or posedge rst)
begin

    if(rst)
    begin

        counter <= 0;
        timer_done <= 0;

    end

    else if(enable)
    begin

        if(counter < TIMER_COUNT)
        begin

            counter <= counter + 1;
            timer_done <= 0;

        end

        else
        begin

            timer_done <= 1;

        end

    end

    else
    begin

        counter <= 0;
        timer_done <= 0;

    end

end
endmodule
