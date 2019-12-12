module WaterController (
    input Clk, Reset,
    input [9:0] DrawX, DrawY,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output player1_dead, player2_dead
);
    
    parameter water_count = 3;
    parameter shortint water_pos_x [water_count-1:0] = '{296,424,392};
    parameter shortint water_pos_y [water_count-1:0] = '{463,463,366};
    parameter logic [2:0] water_types [water_count-1:0] = '{3'd0,3'd1,3'd2};

    logic player1_deads [water_count-1:0];
    logic player2_deads [water_count-1:0];

    /* ---- water Logics ---- */

    always_comb begin

        player1_dead = 1'b0;
        player2_dead = 1'b0;

        for (int i = 0; i < water_count ; i++) begin
            if(player1_deads[i]) player1_dead=1'b1;
            if(player2_deads[i]) player2_dead=1'b1;
        end
    end

    Water water_list [water_count-1:0] (.*, .water_type(water_types), .water_X_Pos(water_pos_x) ,.water_Y_Pos(water_pos_y),
     .player1_dead(player1_deads), .player2_dead(player2_deads));

endmodule


module Water (
    input Clk, Reset,
    input [9:0] DrawX, DrawY,
    input [2:0] water_type,
    input shortint water_X_Pos, water_Y_Pos,
    input shortint player1_top, player1_bottom, player1_left, player1_right,
    input shortint player2_top, player2_bottom, player2_left, player2_right,
    output player1_dead, player2_dead
);
    
    parameter shortint water_width = 80;
    parameter shortint water_height = 5;

    /* ---- Collison Logics ---- */
    logic player1_dead_in, player2_dead_in;

    always_ff @ (posedge Clk) begin
        if(Reset) begin
            player1_dead <= 1'b0;
            player2_dead <= 1'b0;
        end
        else begin
            if(!player1_dead) player1_dead <= player1_dead_in;
            if(!player2_dead) player2_dead <= player2_dead_in;
        end
    end

    always_comb begin
        player1_dead_in = player1_dead;
        player2_dead_in = player2_dead;

        if(water_type!=2'b0 && player1_right > water_X_Pos && player1_left < water_X_Pos+water_width && player1_bottom > water_Y_Pos && player1_top < water_Y_Pos+water_height) player1_dead_in=1'b1;
        if(water_type!=2'b1 && player2_right > water_X_Pos && player2_left < water_X_Pos+water_width && player2_bottom > water_Y_Pos && player2_top < water_Y_Pos+water_height) player2_dead_in=1'b1;
    end

    // Waive Rendering now for that background integrated..

endmodule