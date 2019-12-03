module Collider (
    input integer player_X_Pos, player_Y_Pos,
    output integer player_X_Min, player_X_Max, player_Y_Min, player_Y_Max
);
    
    // level 1 hardcoded raycast hittest version
    // IDEA: change boundary POS according to POS and use default boundary check logic code to accomplish collision detection

    always_comb begin
        //default
        player_X_Min = 0;
        player_X_Max = 639;
        player_Y_Min = 0;
        player_Y_Max = 479;

        //Binary Search
        if(player_X_Pos + 32 < 320) begin
            if(player_X_Pos + 32 < 192) begin
                if(player_Y_Pos >= 351) begin
                    if(player_Y_Pos >= 415) begin
                        player_X_Max = 575;
                        player_Y_Min = 415;
                    end
                    else begin
                        player_X_Max = 256;
                        player_Y_Min = 351;
                        player_Y_Max = 399;
                    end
                end
                else begin
                    if(player_Y_Pos >= 271) begin
                        player_Y_Min = 271;
                        player_Y_Max = 335;
                    end
                end
            end
            else begin
                if(player_X_Pos + 32 < 256) begin
                    if(player_Y_Pos >= 351) begin
                        if(player_Y_Pos < 468) begin
                            player_X_Max = 256;
                            player_Y_Min = 351;
                        end
                        else if(player_Y_Pos >= 415) begin
                            player_X_Max = 575;
                            player_Y_Min = 351;
                        end
                        else begin
                            player_X_Min = 192;
                            player_Y_Min = 351;
                        end
                    end
                    else begin
                        if(player_Y_Pos >= 271) begin
                            player_Y_Min = 271;
                            player_Y_Max = 335;
                        end
                    end
                end
                else if(player_X_Pos + 32 < 288) begin
                    if(player_Y_Pos >= 383) begin
                        player_X_Max = 575;
                        player_Y_Min = 383;
                    end
                    else if(player_Y_Pos >= 271) begin
                        player_Y_Min = 271;
                        player_Y_Max = 335;
                    end
                end
                else begin
                    if(player_Y_Pos >= 383) begin
                        player_X_Max = 575;
                        player_Y_Min = 383;
                    end
                    else if(player_Y_Pos >= 287) begin
                        player_Y_Min = 287;
                        player_Y_Max = 367;
                    end
                end
            end
        end
        else begin
            if(player_X_Pos + 32 < 400) begin
                if(player_Y_Pos >= 383) begin
                    player_X_Max = 575;
                    player_Y_Min = 383;
                end
                else if(player_Y_Pos >= 287) begin
                    player_Y_Min = 287;
                    player_Y_Max = 367;
                end
            end
            else if(player_X_Pos + 32 < 432) begin
                if(player_Y_Pos >= 303) begin
                    player_X_Max = 575;
                    player_Y_Min = 303;
                end
            end
            else begin
                if(player_Y_Pos >= 287) begin
                    player_X_Max = 575;
                    player_Y_Min = 319;
                    player_Y_Max = 415;
                end
            end
        end
    end

endmodule