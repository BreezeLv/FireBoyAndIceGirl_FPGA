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
module  color_mapper ( input logic is_fireboy, is_icegirl,
                       input logic [7:0] bgColor, fireboy_data, icegirl_data,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
	 
// parameter [3:0][23:0] palette = {24'hff00ff,24'h2d2d0c,24'h282807,24'h202000};
logic [23:0] palette [48];
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
assign palette[16] = 24'h726833;
assign palette[17] = 24'h625B2C;
assign palette[18] = 24'h017500;
assign palette[19] = 24'h463D31;
assign palette[20] = 24'h3C4E29;
assign palette[21] = 24'h2E7E84;
assign palette[22] = 24'h447E7A;
assign palette[23] = 24'h298E01;
assign palette[24] = 24'h34CE00;
assign palette[25] = 24'h008001;
assign palette[26] = 24'h009901;
assign palette[27] = 24'h9F4B2F;
assign palette[28] = 24'h4FC07E;
assign palette[29] = 24'h6D97A4;
assign palette[30] = 24'hACAC9F;
assign palette[31] = 24'h3F4223;
assign palette[32] = 24'h00B3FF;
assign palette[33] = 24'h009CDF;
assign palette[34] = 24'h00C5FF;
assign palette[35] = 24'h0081B9;
assign palette[36] = 24'h73D5FF;
assign palette[37] = 24'h67D1FF;
assign palette[38] = 24'h8BDCFF;
assign palette[39] = 24'h63CFFF;
assign palette[40] = 24'h84E7FF;
assign palette[41] = 24'h67FFFF;
assign palette[42] = 24'h52CECE;
assign palette[43] = 24'h286464;
assign palette[44] = 24'h4ABBBB;
assign palette[45] = 24'h3DB3BE;
assign palette[46] = 24'h00597F;
assign palette[47] = 24'h00425F;
	 
    logic [7:0] Red, Green, Blue;

    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    always_comb
    begin
        if (is_fireboy && fireboy_data != 8'b00)
        begin
            Red = palette[fireboy_data[5:0]][23:16];
            Green = palette[fireboy_data[5:0]][15:8];
            Blue = palette[fireboy_data[5:0]][7:0];
        end
        else if (is_icegirl && icegirl_data != 8'b00)
        begin
            Red = palette[icegirl_data[5:0]][23:16];
            Green = palette[icegirl_data[5:0]][15:8];
            Blue = palette[icegirl_data[5:0]][7:0];
        end
        else
        begin
            Red = palette[bgColor[5:0]][23:16];
            Green = palette[bgColor[5:0]][15:8];
            Blue = palette[bgColor[5:0]][7:0];
        end
    end 
    
endmodule
