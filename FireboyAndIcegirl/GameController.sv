module GameController(
    input Clk, Reset,
    input logic gameover, gamewin,

    output logic revive
);

enum logic [2:0] {
    StartMenu, GameStart, InGame, GameOver, GamePass
} state, next_state;

always_ff @ (posedge Clk) begin
    if(Reset) state <= StartMenu;
    else state <= next_state;
end

always_comb begin
    next_state = state;

    unique case(state)
        StartMenu: next_state = GameStart;
        GameStart: next_state = InGame;
        InGame: 
            if(gameover) next_state = GameOver;
            else if(gamewin) next_state = GamePass;
        // GameOver: next_state = StartMenu;
        // GamePass: next_state = StartMenu;
        default: ;
    endcase
end

always_comb begin
    revive = 1'b0;

    unique case(state)
        GameStart: revive=1'b1;
        default: ;
    endcase
end

endmodule
