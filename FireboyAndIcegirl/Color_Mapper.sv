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
module  color_mapper ( input logic is_player,
                       input logic [7:0] bgColor,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
//parameter [7:0][2:0][3:0] palette = {{8'hff,8'h00,8'hff},{8'h2d,8'h2d,8'h0c},{8'h28,8'h28,8'h07},{8'h20,8'h20,8'h00}};
	 
parameter [1:0][23:0] palette = {24'hff00ff,24'h2d2d0c,24'h282807,24'h202000};
//logic [23:0] palette [4];
//assign palette[0]=24'hff00ff;
//assign palette[1]=24'h2d2d0c;
//assign palette[2]=24'h282807;
//assign palette[3]=24'h202000;
	 
    logic [7:0] Red, Green, Blue;

    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    always_comb
    begin
        if (is_player == 1'b1) 
        begin
            // White ball
            Red = 8'hff;
            Green = 8'hff;
            Blue = 8'hff;
        end
        else 
        begin
            Red = palette[bgColor[1:0]][23:16];
            Green = palette[bgColor[1:0]][15:8];
            Blue = palette[bgColor[1:0]][7:0];
        end
    end 
    
endmodule
