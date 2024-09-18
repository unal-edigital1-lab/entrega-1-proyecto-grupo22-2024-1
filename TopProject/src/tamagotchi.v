module tamagotchi (
    input clk,
    input reset,
    input b2, b3, b4,
    input light_sensor,
    input sound_sensor,
    output mosi,
    output sclk,
    output ce,
    output dc,
    output lcd_rst,
    output [0:6] sseg,
    output [7:0] an,
	 output test_led
);

    // State parameters
    localparam SLEEP = 3'd0, FOOD = 3'd1, BATH = 3'd2, MUSIC = 3'd3, EXERCISE = 3'd4, DEAD = 3'd5;

    // Registers for states
    reg [2:0] sleep_state, food_state, bath_state, music_state, exercise_state, health_state;
    reg [2:0] current, face;
	 reg [37:0] timer;
    reg [27:0] test_timer, state_timer;
    reg test_mode, enable;
	 
	 assign test_led = !test_mode;

    // Timers (assuming 50MHz clock)
    localparam SLEEP_TIME = 60 * 60 * 50_000_000;  // 60 minutes
    localparam FOOD_TIME = 10 * 60 * 50_000_000;   // 10 minutes
    localparam BATH_TIME = 20 * 60 * 50_000_000;   // 20 minutes
    localparam MUSIC_TIME = 15 * 60 * 50_000_000;  // 15 minutes
    localparam EXERCISE_TIME = 30 * 60 * 50_000_000; // 30 minutes
    
    localparam HOLD_TIME = 5 * 50_000_000;    // 5 seconds
    localparam FACE_CHANGE_TIME = 2 * 50_000_000;  // 2 second
    localparam SLEEPY_TIME = 5 * 50_000_000;       // 5 seconds

    // FSM_pet instance
    FSM_pet pet_display (
        .clk(clk),
        .reset(reset),
        .face(face),
        .icon(current),
        .mosi(mosi),
        .sclk(sclk),
        .ce(ce),
        .dc(dc),
        .lcd_rst(lcd_rst)
    );

    // 7-segment display data
    reg [39:0] display_data;

    // display_hex instance
    display_hex seg_display (
        .num(display_data),
        .clk(clk),
        .sseg(sseg),
        .an(an),
        .rst(reset)
    );

    // Update display data based on current mode
    always @(*) begin
        case (current)
            SLEEP:   display_data = {5'd13, 5'd14, 5'd15, 2'b0, sleep_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            FOOD:    display_data = {5'd10, 5'd13, 5'd12, 2'b0, food_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            BATH:    display_data = {5'd16, 5'd17, 5'd10, 2'b0, bath_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            MUSIC:   display_data = {5'd18, 5'd19, 5'd13, 2'b0, music_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            EXERCISE: display_data = {5'd20, 5'd21, 5'd20, 2'b0, exercise_state[2:0], 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
            default: display_data = {5'd0, 5'd0, 5'd0, 5'd0, 5'd10, 5'd14, 5'd17, 2'b0, health_state[2:0]};
        endcase
    end

    // Main logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            sleep_state <= 3'd7;
            food_state <= 3'd7;
            bath_state <= 3'd7;
            music_state <= 3'd7;
            exercise_state <= 3'd7;
            health_state <= 3'd7;
            current <= SLEEP;
            face <= 0;
            timer <= 0;
            test_mode <= 0;
            test_timer <= 0;
				state_timer <= 0;
        end else begin
		  
            // Test mode logic
            if (!b2) begin
					if (test_mode) begin
						case (current)
							SLEEP: 	begin
										if (sleep_state) begin
											sleep_state <= sleep_state - 1;
										end else begin
											if (health_state) begin
												health_state <= health_state - 1;
											end else begin
												current <= DEAD;
												face <= 5;
											end
										end
										end
										
							FOOD: 	begin
										if (food_state) begin
											food_state <= food_state - 1;
										end else begin
											if (health_state) begin
												health_state <= health_state - 1;
											end else begin
												current <= DEAD;
												face <= 5;
											end
										end
										end
										
							BATH: 	begin
										if (bath_state) begin
											bath_state <= bath_state - 1;
										end else begin
											if (health_state) begin
												health_state <= health_state - 1;
											end else begin
												current <= DEAD;
												face <= 5;
											end
										end
										end
										
							MUSIC: 	begin
										if (music_state) begin
											music_state <= music_state - 1;
										end else begin
											if (health_state) begin
												health_state <= health_state - 1;
											end else begin
												current <= DEAD;
												face <= 5;
											end
										end
										end
										
							EXERCISE: 	begin
										if (exercise_state) begin
											exercise_state <= exercise_state - 1;
										end else begin
											if (health_state) begin
												health_state <= health_state - 1;
											end else begin
												current <= DEAD;
												face <= 5;
											end
										end
										end
						endcase
					end
                if (test_timer == HOLD_TIME - 1) begin
                    test_mode <= ~test_mode;
                    test_timer <= 0;
                end else begin
                    test_timer <= test_timer + 1;
                end
            end else begin
					test_timer <= 0;
				end

            // Mode switching
            if (!b3 && current != DEAD) begin
                case (current)
                    SLEEP: current <= FOOD;
                    FOOD: current <= BATH;
                    BATH: current <= MUSIC;
                    MUSIC: current <= EXERCISE;
                    EXERCISE: current <= SLEEP;
                endcase
            end

				//Timer logic
				
				//State logic
				
        end
    end
endmodule