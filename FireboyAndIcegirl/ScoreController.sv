module ScoreController (
    input Clk, Reset,
    input [9:0] DrawX, DrawY,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output logic is_score, is_gem,
    output logic [7:0] score_data, gem_data,
	 output logic [3:0] score_hex
);

    parameter gem_count = 2;
    parameter shortint gem_pos [gem_count][2] = '{'{320,440}, '{431,431}};

    parameter shortint font_width = 8;
    parameter shortint font_height = 16;
//    parameter [2:0] font_scale = 2'd2; # for simplicity, we'll just do a hardcode scale x2
    parameter [6:0] font_0_index = 7'h30;
    parameter [9:0] score_start_X_pos = 320-font_width;
    parameter [9:0] score_start_Y_pos = 30-font_height;

    logic [3:0] score, score_in; // score = [0,15]
    logic dead_gems [gem_count-1:0];
    logic is_gems [gem_count-1:0];
    logic [8:0] gems_read_addr [gem_count-1:0];
	 
	 assign score_hex = score; //debug

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            score <= 4'h0;
        end
        else begin
            score <= score_in;
        end
    end

    /* ---- Gem Logics ---- */

    always_comb begin

        score_in = 4'h0;
        is_gem = 1'b0;
        gem_read_addr = 9'h00;
        gem_data = 8'h00;

        for (int i = 0; i < gem_count ; i++) begin
            if(dead_gems[i]) score_in++;
            else if(is_gems[i]) begin
                is_gem = 1'b1;
                gem_read_addr = gems_read_addr[i];
                gem_data = gem_data_buf;
            end
        end
    end

    Gem gem_list [gem_count-1:0] (.*, .gem_X_Pos(gem_pos[0]) ,.gem_Y_Pos(gem_pos[1]),
     .dead(dead_gems), .is_gem(is_gems), .gem_read_addr(gems_read_addr));
    
    // Gem Sprite Data Processing
    logic [8:0] gem_read_addr;
    logic [7:0] gem_data_buf;

    gemROM gemROM_inst(.*, .gem_data_out(gem_data_buf)); // Global GemRom Instance, can be shared assume no overlapping gems

	 
    /* ---- Font Logics ---- */
    logic [9:0] offset_X, offset_Y;
	 logic [9:0] scaled_offset_X, scaled_offset_Y;
	 assign scaled_offset_X = offset_X>>1;
	 assign scaled_offset_Y = offset_Y>>1;

    always_comb begin
        offset_X = DrawX-score_start_X_pos;
        offset_Y = DrawY-score_start_Y_pos;
        is_score = 1'b0;

        if(offset_X>=0 && offset_X<font_width*2 && offset_Y>=0 && offset_Y<font_height*2) begin
            is_score=1'b1;
        end
    end

    logic [10:0] score_read_addr;
    logic [7:0] score_data_buf;

    assign score_read_addr = {font_0_index+{3'b000,score}, scaled_offset_Y[3:0]};
    assign score_data = score_data_buf[font_width-1-scaled_offset_X[2:0]] == 1'b1 ? 8'h08 : 8'h00;
    Font_ROM Font_ROM_inst(.addr(score_read_addr), .data(score_data_buf));

		//Failing module, unknown bug.. seems the module isn't even loaded??
//    Font_Wrapper Font_Wrapper_inst (.*, .font_idx(font_0_index+{3'b000,score}), .data(score_data));

endmodule

module Gem (
    input Clk, Reset,
    input [9:0] DrawX, DrawY,
    input shortint gem_X_Pos, gem_Y_Pos,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output dead, is_gem,
    output logic [8:0] gem_read_addr
);

    parameter shortint gem_width = 24;
    parameter shortint gem_height = 19;

    /* ---- Collison Logics ---- */
    logic dead_in;

    always_ff @ (posedge Clk) begin
        if(Reset) dead <= 1'b0;
        else begin
            if(!dead) dead <= dead_in;
            else dead <= dead;
        end
    end

    always_comb begin
        dead_in = 1'b0;
        if(player1_right > gem_X_Pos && player1_left < gem_X_Pos+gem_width && player1_bottom > gem_Y_Pos && player1_top < gem_Y_Pos+gem_height) dead_in=1'b1;
        if(player2_right > gem_X_Pos && player2_left < gem_X_Pos+gem_width && player2_bottom > gem_Y_Pos && player2_top < gem_Y_Pos+gem_height) dead_in=1'b1;
    end

    /* ---- Sprite Logics ---- */
    // Calculate is_gem logic
    shortint offset_X, offset_Y;

    always_comb begin
        offset_X = DrawX-gem_X_Pos;
        offset_Y = DrawY-gem_Y_Pos;
        is_gem = 1'b0;

        if(offset_X>=0 && offset_X<gem_width && offset_Y>=0 && offset_Y<gem_height) begin
            is_gem=1'b1;
        end
    end

    // Sprite Data Processing ==> Pass to the parent controller for saving Rom space
    assign gem_read_addr = is_gem ? offset_X + offset_Y*gem_width : 19'b00;

endmodule

module gemROM
(
	input [8:0] gem_read_addr,
	input Clk,

	output logic [7:0] gem_data_out
);

    logic [7:0] mem_gem [0:455];

    initial
    begin
        $readmemh("../PNG To Hex/On-Chip Memory/sprite_bytes/gem.txt", mem_gem);
    end

    always_ff @ (posedge Clk)
    begin
        gem_data_out <= mem_gem[gem_read_addr];
    end

endmodule
