`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.07.2026 17:50:18
// Design Name: 
// Module Name: decision_logic
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


module decision_logic(
    input dry,
    input hot,
    input low_humidity,
    input rain,
    input tank_empty,
    output reg watering_request,
    output reg [2:0] inhibit_reason,
    output wire [3:0] env_status
    );

assign env_status = {
    rain,
    low_humidity,
    hot,
    dry
};

localparam NO_INHIBIT      = 3'b000;
localparam RAIN_DETECTED   = 3'b001;
localparam TANK_EMPTY      = 3'b010;
localparam TEMP_TOO_LOW    = 3'b011;
localparam HUMIDITY_HIGH   = 3'b100;
localparam SOIL_NOT_DRY    = 3'b101;


//------------------------------------------------------------
// Decision Logic
//------------------------------------------------------------

always @(*)
begin

    // Default outputs

    watering_request = 1'b0;
    inhibit_reason   = NO_INHIBIT;

    //--------------------------------------------------------
    // Highest Priority : Tank Empty
    //--------------------------------------------------------

    if(tank_empty)
    begin
        watering_request = 1'b0;
        inhibit_reason   = TANK_EMPTY;
    end

    //--------------------------------------------------------
    // Rain Detected
    //--------------------------------------------------------

    else if(rain)
    begin
        watering_request = 1'b0;
        inhibit_reason   = RAIN_DETECTED;
    end

    //--------------------------------------------------------
    // Temperature Too Low
    //--------------------------------------------------------

    else if(!hot)
    begin
        watering_request = 1'b0;
        inhibit_reason   = TEMP_TOO_LOW;
    end

    //--------------------------------------------------------
    // Humidity Already High
    //--------------------------------------------------------

    else if(!low_humidity)
    begin
        watering_request = 1'b0;
        inhibit_reason   = HUMIDITY_HIGH;
    end

    //--------------------------------------------------------
    // Soil Not Dry
    //--------------------------------------------------------

    else if(!dry)
    begin
        watering_request = 1'b0;
        inhibit_reason   = SOIL_NOT_DRY;
    end

    //--------------------------------------------------------
    // Watering Allowed
    //--------------------------------------------------------

    else
    begin
        watering_request = 1'b1;
        inhibit_reason   = NO_INHIBIT;
    end

end

endmodule
