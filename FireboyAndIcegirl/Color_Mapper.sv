//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input logic is_fireboy,
                       input logic [7:0] bgColor, fireboy_data,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
	 
// parameter [3:0][23:0] palette = {24'hff00ff,24'h2d2d0c,24'h282807,24'h202000};
logic [23:0] palette [16];
assign palette[0] = 24'hFF00FF;
assign palette[1] = 24'h2D2D0C;
assign palette[2] = 24'h282807;
assign palette[3] = 24'h202000;
assign palette[4] = 24'h000000;
assign palette[5] = 24'h570C0C;
assign palette[6] = 24'hD21212;
assign palette[7] = 24'hFF0000;
assign palette[8] = 24'hFFD400;
assign palette[9] = 24'hFF9800;
assign palette[10] = 24'hFF3300;
assign palette[11] = 24'hF73C04;
assign palette[12] = 24'hCE0000;
assign palette[13] = 24'h8F5600;
assign palette[14] = 24'h4F2F00;
assign palette[15] = 24'h6F5B00;
	 
    logic [7:0] Red, Green, Blue;

    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    always_comb
    begin
        if (is_fireboy && fireboy_data != 8'b00) 
        begin
            Red = palette[fireboy_data[3:0]][23:16];
            Green = palette[fireboy_data[3:0]][15:8];
            Blue = palette[fireboy_data[3:0]][7:0];
        end
        else 
        begin
            Red = palette[bgColor[3:0]][23:16];
            Green = palette[bgColor[3:0]][15:8];
            Blue = palette[bgColor[3:0]][7:0];
        end
    end 
    
endmodule
