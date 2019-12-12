module GameController(
    input Clk, Reset,
    input logic gameover, gamewin,
    input logic confirm,

    output logic revive,
    input AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
    output logic AUD_DACDAT, AUD_XCK, I2C_SCLK, I2C_SDAT,
    input logic jump
);

enum logic [2:0] {
    StartMenu, GameStart, InGame, GameOver, GamePass
} state, next_state;

logic [15:0] AudioData [0:14373];
int audiocounter, audiocounter_in;
int audioclkcounter, audioclkcounter_in;
initial begin
	  $readmemh("../PNG To Hex/Sound/d8000.txt", AudioData);
end

logic [15:0] LData, RData, LData_in, RData_in;
logic Init, Init_Finish, ADC_Full, Data_over;
logic [31:0] ADCData;

audio_interface audio(.LDATA(LData), .RDATA(RData), .clk(Clk), .Reset(Reset),
	.INIT(Init), .INIT_FINISH(Init_Finish), .adc_full(ADC_Full),
	.data_over(Data_over), .AUD_MCLK(AUD_XCK), .AUD_BCLK(AUD_BCLK), .AUD_DACDAT(AUD_DACDAT),
	.AUD_ADCDAT(AUD_ADCDAT), .AUD_DACLRCK(AUD_DACLRCK), .AUD_ADCLRCK(AUD_ADCLRCK), 
	.I2C_SDAT(I2C_SDAT), .I2C_SCLK(I2C_SCLK), .ADCDATA(ADCData));

always_ff @ (posedge Clk) begin
    if(Reset) state <= StartMenu;
    else begin
        state <= next_state;
        LData <= LData_in;
		RData <= RData_in;
        audiocounter <= audiocounter_in;
        audioclkcounter <= audioclkcounter_in;
    end
end

always_comb begin
    next_state = state;

    unique case(state)
        StartMenu: begin if(Init_Finish) next_state = GameStart; end
        GameStart: next_state = InGame;
        InGame: 
            if(gameover) next_state = GameOver;
            else if(gamewin) next_state = GamePass;
        GameOver:
            if(confirm) next_state = StartMenu;
        GamePass:
            if(confirm) next_state = StartMenu;
        default: ;
    endcase
end

always_comb begin
    revive = 1'b0;
    Init = 1'b0;
    LData_in = LData;
	RData_in = RData;
    audiocounter_in = audiocounter;
    audioclkcounter_in = audioclkcounter;

    unique case(state)
        StartMenu: begin Init = 1'b1; audiocounter_in = 0; audioclkcounter_in = 0; end
        GameStart: begin 
            revive=1'b1; 
        end
        InGame: begin
            
            if(jump) begin
                // audiocounter_in = 0; 
                // audioclkcounter_in = 0;
                audioclkcounter_in = audioclkcounter + 1;
                if(audioclkcounter == 6249) begin
                    audiocounter_in = audiocounter + 1;
                    if(audiocounter == 14373) begin 
                        audiocounter_in = 0; 
                    end
                    audioclkcounter_in = 0;
                end
                LData_in = AudioData[audiocounter];
                RData_in = AudioData[audiocounter];
            end
        end
        default: ;
    endcase
end
endmodule
