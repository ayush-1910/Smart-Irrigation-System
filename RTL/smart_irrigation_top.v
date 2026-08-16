`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 21:39:40
// Design Name: 
// Module Name: smart_irrigation_top
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


module smart_irrigation_top(
    input wire clk,
    input wire rst,

    input wire [7:0] moisture,
    input wire [7:0] temperature,
    input wire [7:0] humidity,

    input wire rain,
    input wire tank_empty,

    input wire manual_mode,
    input wire manual_cmd,

    output wire pump,
    output wire [4:0] status,
    output wire [2:0] state,
    output wire [2:0] inhibit_reason,
    output wire [3:0] env_status,
    output wire [7:0] diagnostic
    );
wire dry;
wire wet;
wire hot;
wire low_humidity;

wire watering_request;

wire timer_enable;
wire timer_done;

environment_monitor ENV_MON
(
    .moisture(moisture),
    .temperature(temperature),
    .humidity(humidity),

    .dry(dry),
    .wet(wet),
    .hot(hot),
    .low_humidity(low_humidity)
);

decision_logic DECISION
(
    .dry(dry),
    .hot(hot),
    .low_humidity(low_humidity),

    .rain(rain),
    .tank_empty(tank_empty),

    .watering_request(watering_request),
    .inhibit_reason(inhibit_reason),
    .env_status(env_status)
);

generic_timer
#(
    .COUNT_WIDTH(8),
    .TIMER_COUNT(100)
)
TIMER
(
    .clk(clk),
    .rst(rst),

    .enable(timer_enable),

    .timer_done(timer_done)
);

irrigation_fsm FSM
(
    .clk(clk),
    .rst(rst),

    .watering_request(watering_request),
    .wet(wet),

    .tank_empty(tank_empty),

    .manual_mode(manual_mode),
    .manual_cmd(manual_cmd),

    .timer_done(timer_done),
    .timer_enable(timer_enable),

    .pump(pump),

    .status(status),
    .state(state),
    .dry(dry),
    .hot(hot),
    .low_humidity(low_humidity),
    .rain(rain),
    .inhibit_reason(inhibit_reason),
    .diagnostic(diagnostic)
);

endmodule
