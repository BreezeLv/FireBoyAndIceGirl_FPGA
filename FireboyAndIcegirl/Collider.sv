module Collider (
    input integer player_X_Pos, player_Y_Pos,
    output integer player_X_Min, player_X_Max, player_Y_Min, player_Y_Max
);
    
    // level 1 hardcoded raycast hittest version
    // IDEA: change boundary POS according to POS and use default boundary check logic code to accomplish collision detection

    always_comb begin
        // default
        player_X_Min = 23;                          // ********   32 * 48
        player_X_Max = 617;                         // *      *
        player_Y_Min = 14;                          // *      *                         
        player_Y_Max = 463;                         // *      *
                                                    // *      *
        // Binary Search                            // ********   
        if(player_X_Pos + 24 < 320) begin      // right part of screen
            if(player_X_Pos + 24 < 88) begin  // 
                if(player_Y_Pos >= 400) begin
                    player_X_Max = 571;
                    player_Y_Min = 400;
                end
                else if(player_Y_Pos >= 336) begin //335
                    player_X_Max = 256;
                    player_Y_Min = 336;
                    player_Y_Max = 399;   //
                end
                else if(player_Y_Pos >= 129) begin
                    if(player_Y_Pos >= 264) begin
                        player_Y_Min = 192;
                        player_Y_Max = 335;
                    end
                    else if(player_Y_Pos + 48 <= 255) begin
                        player_Y_Min = 192;
                        player_Y_Max = 335;
                    end
                    else begin
                        player_X_Max = 88;
                        player_Y_Min = 192;
                        player_Y_Max = 335;
                    end
                end
                else begin
                    player_Y_Max = 128;
                end
            end
            else if(player_X_Pos + 24 < 102) begin  // 
                if(player_Y_Pos >= 400) begin
                    player_X_Max = 571;
                    player_Y_Min = 400;
                end
                else if(player_Y_Pos >= 336) begin //335
                    player_X_Max = 256;
                    player_Y_Min = 336;
                    player_Y_Max = 399;   //
                end
                else if(player_Y_Pos >= 257) begin
                    player_Y_Min = 257;
                    player_Y_Max = 335;
                end
                else if(player_Y_Pos >= 129) begin
                    player_Y_Min = 191;
                    player_Y_Max = 256;
                end
                else begin
                    player_Y_Max = 128;
                end
            end
            else if(player_X_Pos + 24 < 169) begin  // 
                if(player_Y_Pos >= 400) begin
                    player_X_Max = 571;
                    player_Y_Min = 400;
                end
                else if(player_Y_Pos >= 336) begin //335
                    player_X_Max = 256;
                    player_Y_Min = 336;
                    player_Y_Max = 399;   //
                end
                else if(player_Y_Pos >= 257) begin
                    player_Y_Min = 257;
                    player_Y_Max = 335;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 129) begin
                    player_Y_Max = 192;
                    player_X_Min = 102;
                end
                else begin
                    if(player_Y_Pos >= 86) begin
                        player_Y_Max = 192;
                    end
                    else if(player_Y_Pos + 48 <= 78) begin
                        player_Y_Max = 192;
                    end
                    else begin
                        player_X_Max = 169;
                        player_Y_Max = 192;
                    end
                end
            end
            else if(player_X_Pos + 24 < 200) begin  // 
                if(player_Y_Pos >= 400) begin
                    player_X_Max = 571;
                    player_Y_Min = 400;
                end
                else if(player_Y_Pos >= 336) begin //335
                    player_X_Max = 256;
                    player_Y_Min = 336;
                    player_Y_Max = 399;   //
                end
                else if(player_Y_Pos >= 257) begin
                    player_Y_Min = 257;
                    player_Y_Max = 335;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 79) begin
                    if(player_Y_Pos >= 138) begin
                        player_Y_Min = 79;
                        player_Y_Max = 192;
                    end
                    else begin
                        player_Y_Min = 79;
                        player_Y_Max = 192;
                        player_X_Max = 200;
                    end
                end
                else begin
                    player_Y_Max = 78;
                end
            end
            else if(player_X_Pos + 24 < 215) begin  // 
                if(player_Y_Pos >= 400) begin
                    player_X_Max = 571;
                    player_Y_Min = 400;
                end
                else if(player_Y_Pos >= 336) begin //335
                    player_X_Max = 256;
                    player_Y_Min = 336;
                    player_Y_Max = 399;   //
                end
                else if(player_Y_Pos >= 257) begin
                    player_Y_Min = 257;
                    player_Y_Max = 335;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 76) begin
                    player_Y_Min = 138;
                    player_Y_Max = 192;
                end
                else begin
                    player_Y_Max = 78;
                end
            end                                                //DONE 
            else if(player_X_Pos + 24 < 256) begin 
                if(player_Y_Pos >= 336) begin
                    if(player_Y_Pos >= 408) begin
                        player_X_Max = 571;
                        player_Y_Min = 336;
                    end
                    else if(player_Y_Pos + 48 <= 399) begin
                        player_X_Max = 256;
                        player_Y_Min = 336;
                    end
                    else begin
                        player_X_Min = 215;
                        player_Y_Min = 336;
                    end
                end
                else if(player_Y_Pos >= 257) begin
                    player_Y_Min = 257;
                    player_Y_Max = 335;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 95) begin
                    player_Y_Min = 138;
                    player_Y_Max = 192;
                end
                else begin
                    player_Y_Max = 94;
                end                                    //DONE
            end
            else if(player_X_Pos + 24 < 280) begin
                if(player_Y_Pos >= 336) begin
                    player_X_Max = 571;
                    player_Y_Min = 372;
                end
                else if(player_Y_Pos >= 257) begin    //255
                    player_Y_Min = 257;
                    player_Y_Max = 335;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 138;
                    player_Y_Max = 192;
                end
                else begin
                    player_Y_Min = 38;
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 296) begin
                if(player_Y_Pos >= 344) begin
                    player_X_Max = 571;
                    player_Y_Min = 366;
                end
                else if(player_Y_Pos >= 257) begin    //255
                    player_Y_Min = 257;
                    player_Y_Max = 343;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 109) begin
                    if(player_Y_Pos >= 138) begin
                        player_Y_Min = 109;
                        player_Y_Max = 192;
                    end
                    else begin
                        player_Y_Min = 109;
                        player_Y_Max = 192;
                        player_X_Min = 279;
                    end
                end
                else begin
                    player_Y_Min = 38;
                    player_Y_Max = 110;
                end
            end
            else begin
                if(player_Y_Pos >= 354) begin
                    player_X_Max = 571;
                    player_Y_Min = 366;
                    player_Y_Max = 472;
                end
                else if(player_Y_Pos >= 257) begin
                    player_Y_Min = 271;
                    player_Y_Max = 353;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 192;
                end
                else begin
                    player_Y_Min = 38;
                    player_Y_Max = 110;
                end
            end
        end
        else begin
            if(player_X_Pos + 24 < 328) begin  // 
                if(player_Y_Pos >= 367) begin
                    player_X_Max = 569;
                    player_Y_Min = 367;
                    player_Y_Max = 472;
                end
                else if(player_Y_Pos >= 257) begin
                    player_Y_Min = 273;
                    player_Y_Max = 366;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 256;
                end
                else if(player_Y_Pos >= 109) begin
                    if(player_Y_Pos >= 139) begin
                        player_Y_Min = 109;
                        player_Y_Max = 192;
                        player_X_Max = 328;
                    end
                    else begin
                        player_Y_Min = 109;
                        player_Y_Max = 192;
                    end
                end
                else begin
                    player_Y_Min = 38;
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 376) begin  // 
                if(player_Y_Pos >= 367) begin
                    player_X_Max = 569;
                    player_Y_Min = 367;
                    player_Y_Max = 472;
                end
                else if(player_Y_Pos >= 273) begin
                    player_Y_Min = 273;
                    player_Y_Max = 366;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 272;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 160;
                end
                else begin
                    player_Y_Min = 38;
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 424) begin  // 
                if(player_Y_Pos >= 367) begin
                    player_X_Max = 569;
                    player_Y_Min = 367;
                end
                else if(player_Y_Pos >= 273) begin
                    player_Y_Min = 273;
                    player_Y_Max = 366;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 272;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 160;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 440) begin  // 
                if(player_Y_Pos >= 367) begin
                    player_X_Max = 569;
                    player_Y_Min = 367;
                    player_Y_Max = 472;
                end
                else if(player_Y_Pos >= 273) begin
                    player_Y_Min = 273;
                    player_Y_Max = 366;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 272;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 160;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 472) begin  // 
                if(player_Y_Pos >= 367) begin
                    player_X_Max = 569;
                    player_Y_Min = 367;
                    player_Y_Max = 472;
                end
                else if(player_Y_Pos >= 273) begin
                    player_Y_Min = 273;
                    player_Y_Max = 366;
                end
                else if(player_Y_Pos >= 177) begin
                    player_Y_Min = 200;
                    player_Y_Max = 272;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 176;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 504) begin  // 
                if(player_Y_Pos >= 367) begin
                    player_X_Max = 569;
                    player_Y_Min = 367;
                    player_Y_Max = 472;
                end
                else if(player_Y_Pos >= 273) begin
                    player_Y_Min = 273;
                    player_Y_Max = 366;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 193;
                    player_Y_Max = 272;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 192;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 536) begin  // 
                if(player_Y_Pos >= 367) begin
                    player_X_Max = 569;
                    player_Y_Min = 367;
                end
                else if(player_Y_Pos >= 273) begin
                    player_Y_Min = 273;
                    player_Y_Max = 366;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 208;
                    player_Y_Max = 272;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 192;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 550) begin  // 
                if(player_Y_Pos >= 375) begin
                    player_X_Max = 569;
                    player_Y_Min = 375;
                end
                else if(player_Y_Pos >= 273) begin
                    player_Y_Min = 288;
                    player_Y_Max = 374;
                end
                else if(player_Y_Pos >= 193) begin
                    player_Y_Min = 208;
                    player_Y_Max = 272;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 192;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 569) begin  // 
                if(player_Y_Pos >= 273) begin
                    if(player_Y_Pos >= 373) begin
                        player_Y_Min = 296;
                    end
                    else if(player_Y_Pos + 48 <= 366) begin
                        player_Y_Min = 296;
                    end
                    else begin
                        player_Y_Min = 296;
                        player_X_Min = 550;
                    end
                    if(player_Y_Pos >= 410) begin
                        player_Y_Min = 296;
                        player_X_Max = 569;
                    end
                    else begin
                        player_Y_Min = 296;  
                    end
                end
                else if(player_Y_Pos >= 109) begin
                    if(player_Y_Pos >= 217) begin
                        player_Y_Min = 109;
                        player_Y_Max = 272;
                    end
                    else if(player_Y_Pos + 48 <= 192) begin
                        player_Y_Min = 109;
                        player_Y_Max = 272;
                    end
                    else begin
                        player_Y_Min = 109;
                        player_Y_Max = 272;
                        player_X_Min = 550;
                    end
                end
                else begin
                    player_Y_Max = 110;
                end
            end
            else if(player_X_Pos + 24 < 585) begin  // 
                if(player_Y_Pos >= 273) begin
                    player_Y_Min = 312;
                    player_Y_Max = 424;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 272;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
//             else if(player_X_Pos + 24 < 560) begin
// //                if(player_Y_Pos + 48 >= 367 && player_Y_Pos < 383) player_X_Min = 528;
//                 if(player_Y_Pos >= 303) begin
//                     player_X_Max = 575;
//                     player_Y_Min = 303;
//                 end
//             end
            else begin
                if(player_Y_Pos >= 273) begin
                    player_Y_Min = 320;
                    player_Y_Max = 415;
                end
                else if(player_Y_Pos >= 109) begin
                    player_Y_Min = 109;
                    player_Y_Max = 272;
                end
                else begin
                    player_Y_Max = 110;
                end
            end
        end
    end

endmodule