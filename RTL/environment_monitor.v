`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 17:21:06
// Design Name: 
// Module Name: environment_monitor
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


module environment_monitor #(
    parameter LOW_MOISTURE  = 20,
    parameter HIGH_MOISTURE = 70,
    parameter HIGH_TEMP     = 30,
    parameter LOW_HUMIDITY  = 70
)(
    input [7:0] moisture,
    input [7:0] temperature,
    input [7:0] humidity,
    output dry,
    output wet,
    output hot,
    output low_humidity);
    
assign dry          = (moisture < LOW_MOISTURE);

assign wet          = (moisture > HIGH_MOISTURE);

assign hot          = (temperature > HIGH_TEMP);

assign low_humidity = (humidity < LOW_HUMIDITY);

    
endmodule
