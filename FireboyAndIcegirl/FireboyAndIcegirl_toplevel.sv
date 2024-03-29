//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module FireboyAndIcegirl_toplevel( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,    //SDRAM Clock
            input AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
            output logic AUD_DACDAT, AUD_XCK, I2C_SCLK, I2C_SDAT
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;

    //
    logic [9:0] DrawX, DrawY;
    logic is_ball;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     final_project nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // VGA controller instantiation
    VGA_controller vga_controller_instance(.*, .Reset(Reset_h));

    // Control signals
    logic revive;
    GameController GameController_inst(.*, .jump(fireboy_jump | icegirl_jump), .Reset(Reset_h), .gameover(player1_dead|player2_dead), .gamewin(player1_win&player2_win));

    // Background Control
    logic [7:0] bg_data;
    bgController bgCtl_inst(.*);

    // Player Control
    logic is_fireboy, is_icegirl;
    logic [7:0] fireboy_data, icegirl_data;
    logic player1_win, player2_win;
    FireBoy FireBoy_inst(.*, .frame_clk(~VGA_VS));
    IceGirl IceGirl_inst(.*, .frame_clk(~VGA_VS));
    
    // Multiple Key Press Buffer/Middler
    logic fireboy_jump, fireboy_left, fireboy_right, icegirl_jump, icegirl_left, icegirl_right;
    logic confirm;
    KeycodeMapper keycodeMapper_inst(.*);

    // Score Display
    shortint player1_top, player1_bottom, player1_left, player1_right;
    shortint player2_top, player2_bottom, player2_left, player2_right;
    logic is_score, is_gem;
    logic [7:0] score_data, gem_data;
    ScoreController ScoreController_inst(.*, .Reset(revive));
	 logic [3:0] score_hex;

    // Elevator Control
    logic is_collide_player1, is_collide_player2;
    shortint player1_X_Min, player1_X_Max, player1_Y_Min, player1_Y_Max;
    shortint player2_X_Min, player2_X_Max, player2_Y_Min, player2_Y_Max;
    logic is_elevator, is_switch;
    logic [7:0] elevator_data, switch_data;
    ElevatorController ElevatorController_inst(.*, .frame_clk(~VGA_VS), .Reset(revive));

    // Water Control
    logic player1_dead, player2_dead;
    WaterController WaterController_inst(.*, .Reset(revive));

    // Sprite Renderer
    color_mapper color_instance(.*);
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (score_hex, HEX0);
    HexDriver hex_inst_1 ({3'b110,is_collide_player1}, HEX1);
    
endmodule
