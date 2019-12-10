module Collider (
    input integer player_X_Pos, player_Y_Pos,
    output integer player_X_Min, player_X_Max, player_Y_Min, player_Y_Max
);
    
    // level 1 hardcoded raycast hittest version
    // IDEA: change boundary POS according to POS and use default boundary check logic code to accomplish collision detection

    always_comb begin
        // default
        player_X_Min = 19;                          // ********   32 * 48
        player_X_Max = 620;                         // *      *
        player_Y_Min = 30;                          // *      *                         
        player_Y_Max = 463;                         // *      *
                                                    // *      *
        // Binary Search                            // ********   
        if(player_X_Pos + 32 < 320) begin      // right part of screen
            if(player_X_Pos + 32 < 219) begin  // 
                if(player_Y_Pos >= 399) begin
                    player_X_Max = 571;
                    player_Y_Min = 399;
                end
                else if(player_Y_Pos >= 351-16) begin //335
                    player_X_Max = 256;
                    player_Y_Min = 335;
                    player_Y_Max = 399;   //
                end
                else if(player_Y_Pos >= 271-16) begin
                    player_Y_Min = 271-16;
                    player_Y_Max = 335;
                end
            end                                                //DONE 
            else if(player_X_Pos + 32 < 256) begin 
                if(player_Y_Pos >= 351-16) begin
                    if(player_Y_Pos >= 415) begin
                        player_X_Max = 571;
                        player_Y_Min = 351-16;
                    end
                    else if(player_Y_Pos + 48 <= 399) begin
                        player_X_Max = 256;
                        player_Y_Min = 351-16;
                    end
                    else begin
                        player_X_Min = 211;
                        player_Y_Min = 351-16;
                    end
                end
                else if(player_Y_Pos >= 271-16) begin
                    player_Y_Min = 271-16;
                    player_Y_Max = 335;      
                end                                         //DONE
            end
            else if(player_X_Pos + 32 < 288) begin
                if(player_Y_Pos >= 361) begin
                    player_X_Max = 571;
                    player_Y_Min = 361;
                end
                else if(player_Y_Pos >= 271-16) begin    //255
                    player_Y_Min = 271-16;
                    player_Y_Max = 335;
                end
            end
            else begin
                if(player_Y_Pos >= 361) begin
                    player_X_Max = 571;
                    player_Y_Min = 361;
                end
                else if(player_Y_Pos >= 287-16) begin
                    player_Y_Min = 287-16;
                    player_Y_Max = 367;
                end
            end
        end
        else begin
            if(player_X_Pos + 32 < 528) begin
                if(player_Y_Pos >= 361) begin
                    player_X_Max = 575;
                    player_Y_Min = 361;
                end
                else if(player_Y_Pos >= 287-16) begin
                    player_Y_Min = 287-16;
                    player_Y_Max = 367;
                end
            end
            else if(player_X_Pos + 32 < 560) begin
//                if(player_Y_Pos + 48 >= 367 && player_Y_Pos < 383) player_X_Min = 528;
                if(player_Y_Pos >= 303) begin
                    player_X_Max = 575;
                    player_Y_Min = 303;
                end
            end
            else begin
                if(player_Y_Pos >= 287) begin
                    player_Y_Min = 319;
                    player_Y_Max = 415;
                end
            end
        end
    end

endmodule